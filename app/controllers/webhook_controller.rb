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
        if event.message['text'][-5, 2] == '毎週' && event.message['text'][-2, 2] == '曜日'
          message = create_weekly_time_message(event)
        else
        message = create_response_message(event)
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
    return message
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
      schedule_type = 'specific_day'
      post_date = event['postback']['params']['datetime']
      post_time = DateTime.parse(event['postback']['params']['datetime'])
      post_hour = post_time.hour
      post_minute = post_time.minute
      new_schedule = Schedule.new(
        title: title,
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: schedule_type,
        post_date: post_date,
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
      schedule_type = 'everyday'
      post_time = DateTime.parse(event['postback']['params']['time'])
      post_hour = post_time.hour
      post_minute = post_time.minute
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
      schedule_type = 'everyweek'
      post_day = event['postback']['data'][-3, 3]
      title = post_data.delete!("\n毎週").delete(post_day)
      case post_day
      when '月曜日'
        post_day = 'Monday'
      when '火曜日'
        post_day = 'Tuesday'
      when '水曜日'
        post_day = 'Wednesday'
      when '木曜日'
        post_day = 'Thursday'
      when '金曜日'
        post_day = 'Friday'
      when '土曜日'
        post_day = 'Saturday'
      when '日曜日'
        post_day = 'Sunday'
      end
      post_time = DateTime.parse(event['postback']['params']['time'])
      post_hour = post_time.hour
      post_minute = post_time.minute
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

    when /毎月/
      title = post_data.delete!("\n毎月")
      schedule_type = 'everymonth'
      post_date = event['postback']['params']['datetime']
      post_time = DateTime.parse(event['postback']['params']['datetime'])
      post_hour = post_time.hour
      post_minute = post_time.minute
      new_schedule = Schedule.new(
        title: title,
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: schedule_type,
        post_date: post_date,
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

  def create_weekly_schedule(event)
    post_data = event['postback']['data']
    talk_room_type_id = TalkRoomType.find_by(type_name: event['source']['type']).id
    target_id_type = TalkRoomType.find_by(id: talk_room_type_id).target_id_type
    talk_room_id = event['source'][target_id_type]
    create_user_id = event['source']['userId']

    title = post_data.delete!("\n一日だけ")
    schedule_type = 'specific_day'
    post_date = event['postback']['params']['datetime']
    post_time = DateTime.parse(event['postback']['params']['datetime'])
    post_hour = post_time.hour
    post_minute = post_time.minute
    new_schedule = Schedule.new(
      title: title,
      talk_room_type_id: talk_room_type_id,
      talk_room_id: talk_room_id,
      schedule_type: schedule_type,
      post_date: post_date,
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
      end
    end
    return message
  end

  def create_default_message
    message = {
      type: 'text',
      text: 'タイトルとカテゴリを入力してください' \
      "\nカテゴリ：「一日だけ」・「毎日」・「毎週」・「毎月」\n例：\n海水浴\n毎日"
    }
    return message
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
    return message
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
    return message
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
    return message
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
    return message
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
    return message
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
    return message
  end
end
