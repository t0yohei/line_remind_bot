class WebhookController < ApplicationController
  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Postback
        message = create_schedule(event)
      when Line::Bot::Event::Message
        message = if !event.message['text'].nil? && event.message['text'][-2, 2] == '曜日'
                    create_weekly_time_message(event)
                  else
                    create_response_message(event)
                  end
      end
      client.reply_message(event['replyToken'], message)
    end
    head :ok
  end

  private

  def create_weekly_time_message(event)
    message = {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '時間を選択',
        text: event.message['text'],
        actions: [
          {
            type: 'datetimepicker',
            label: '日時を指定',
            data: event.message['text'],
            mode: 'time'
          }
        ]
      }
    }
    message
  end

  def create_schedule(event)
    post_data = event['postback']['data']
    talk_room_type_id = TalkRoomType.find_by(type_name: event['source']['type']).id
    target_id_type = TalkRoomType.find_by(id: talk_room_type_id).target_id_type
    talk_room_id = event['source'][target_id_type]
    create_user_id = event['source']['userId']

    case post_data
    when /一日だけ/
      title = post_data.delete!("\n一日だけ")
      schedule_type = 0
      post_date = Time.zone.parse(event['postback']['params']['datetime'])
      post_year = post_date.year
      post_month = post_date.mon
      post_day = post_date.day
      post_hour = post_date.hour
      post_minute = post_date.min
      new_schedule = Schedule.new(
        title: title,
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: schedule_type,
        post_year: post_year,
        post_month: post_month,
        post_day: post_day,
        post_hour: post_hour,
        post_minute: post_minute,
        create_user_id: create_user_id
      )
      if new_schedule.save
        return create_complete_message(event)
      else
        return 'エラーが発生しました'
      end

    when /毎日/
      title = post_data.delete!("\n毎日")
      schedule_type = 1
      post_time = Time.zone.parse(event['postback']['params']['time'])
      post_hour = post_time.hour
      post_minute = post_time.min
      new_schedule = Schedule.new(
        title: title,
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: schedule_type,
        post_hour: post_hour,
        post_minute: post_minute,
        create_user_id: create_user_id
      )
      if new_schedule.save
        return create_complete_message(event)
      else
        return 'エラーが発生しました'
      end
    when /毎週/
      schedule_type = 2
      post_day = event['postback']['data'][-3, 3]
      title = post_data.delete("\n毎週").delete('その他').delete(post_day)
      case post_day
      when '日曜日'
        post_wday = Schedule.post_wdays[:Sunday]
      when '月曜日'
        post_wday = Schedule.post_wdays[:Monday]
      when '火曜日'
        post_wday = Schedule.post_wdays[:Tuesday]
      when '水曜日'
        post_wday = Schedule.post_wdays[:Wednesday]
      when '木曜日'
        post_wday = Schedule.post_wdays[:Thursday]
      when '金曜日'
        post_wday = Schedule.post_wdays[:Friday]
      when '土曜日'
        post_wday = Schedule.post_wdays[:Saturday]
      end
      post_time = Time.zone.parse(event['postback']['params']['time'])
      post_hour = post_time.hour
      post_minute = post_time.min
      new_schedule = Schedule.new(
        title: title,
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: schedule_type,
        post_wday: post_wday,
        post_hour: post_hour,
        post_minute: post_minute,
        create_user_id: create_user_id
      )
      if new_schedule.save
        return create_complete_message(event)
      else
        return 'エラーが発生しました'
      end

    when /毎月/
      title = post_data.delete!("\n毎月")
      schedule_type = 3
      post_date = Time.zone.parse(event['postback']['params']['datetime'])
      post_day = post_date.day
      post_hour = post_date.hour
      post_minute = post_date.min
      new_schedule = Schedule.new(
        title: title,
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: schedule_type,
        post_day: post_day,
        post_hour: post_hour,
        post_minute: post_minute,
        create_user_id: create_user_id
      )
      if new_schedule.save
        return create_complete_message(event)
      else
        return 'エラーが発生しました'
      end

    end
  end

  def create_response_message(event)
    case event.type
    when Line::Bot::Event::MessageType::Text
      input_text = event.message['text']
      case input_text
      when /予定を登録/
        message = create_default_message
      when /一日だけ/
        message = create_specific_day_message(event)
      when /毎日/
        message = create_daily_message(event)
      when /毎週/ && /曜日/
        message = {
          type: 'text',
          text: event.message['text'] + 'が入力されました'
        }
      when /毎週/ && /その他/
        message = create_another_weekly_message(event)
      when /毎週/
        message = create_weekly_message(event)
      when /毎月/
        message = create_monthly_message(event)
      when /予定を削除/
        message = create_default_delete_message
      when /削除/
        message = create_deleted_message
        delete_schedule(event)
      end
    end
    message
  end

  def create_default_message
    text = <<~DEFAULT_MESSAGE
      ■タイトルとカテゴリを入力してください
      ■カテゴリ：「一日だけ」・「毎日」・「毎週」・「毎月」
      ----例----
      海水浴
      毎日
    DEFAULT_MESSAGE
    message = {
      type: 'text',
      text: text
    }
    message
  end

  def create_default_delete_message
    target_list = Schedule.inactive.pluck(:title).join(',')
    text = <<~DELETE_DEFAULT_MESSAGE
      ■削除するスケジュールのタイトルとカテゴリを入力してください
      ■カテゴリ：「一日だけ」・「毎日」・「毎週」・「毎月」
      ■予定一覧：#{target_list}
      ----例----
      削除
      海水浴
      毎日
    DELETE_DEFAULT_MESSAGE
    message = {
      type: 'text',
      text: text
    }
    message
  end

  def create_complete_message(event)
    case event['postback']['params'].first.first
    when /datetime/
      message = {
        type: 'text',
        text: event['postback']['params']['datetime'] + ' が入力されました'
      }
    when /time/
      message = {
        type: 'text',
        text: event['postback']['params']['time'] + ' が入力されました'
      }
    end
    message
  end

  def create_specific_day_message(event)
    message = {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '一日だけ',
        text: event.message['text'],
        actions: [
          {
            type: 'datetimepicker',
            label: '日時を指定',
            data: event.message['text'],
            mode: 'datetime'
          }
        ]
      }
    }
    message
  end

  def create_daily_message(event)
    message = {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '毎日',
        text: event.message['text'],
        actions: [
          {
            type: 'datetimepicker',
            label: '時間を指定',
            data: event.message['text'],
            mode: 'time'
          }
        ]
      }
    }
    message
  end

  def create_weekly_message(event)
    message = {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '曜日選択',
        text: event.message['text'],
        actions: [
          {
            type: 'message',
            label: '月曜日',
            text: event.message['text'] + '月曜日'
          },
          {
            type: 'message',
            label: '火曜日',
            text: event.message['text'] + '火曜日'
          },
          {
            type: 'message',
            label: '水曜日',
            text: event.message['text'] + '水曜日'
          },
          {
            type: 'message',
            label: 'その他の曜日',
            text: event.message['text'] + 'その他'
          }
        ]
      }
    }
    message
  end

  def create_another_weekly_message(event)
    message = {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '曜日選択',
        text: event.message['text'] + "\n曜日を選択してください",
        actions: [
          {
            type: 'message',
            label: '木曜日',
            text: event.message['text'] + '木曜日'
          },
          {
            type: 'message',
            label: '金曜日',
            text: event.message['text'] + '金曜日'
          },
          {
            type: 'message',
            label: '土曜日',
            text: event.message['text'] + '土曜日'
          },
          {
            type: 'message',
            label: '日曜日',
            text: event.message['text'] + '日曜日'
          }
        ]
      }
    }
    message
  end

  def create_monthly_message(event)
    message = {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '毎月',
        text: event.message['text'],
        actions: [
          {
            type: 'datetimepicker',
            label: '日時を指定',
            data: event.message['text'],
            mode: 'datetime'
          }
        ]
      }
    }
    message
  end
end
