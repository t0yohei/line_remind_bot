class WebhookController < ApplicationController
  before_action :validate_signature, only: :callback

  def callback
    @api_client.events.each do |event|
      case event
      when Line::Bot::Event::Postback
        create_schedule(event)
      when Line::Bot::Event::Message
        @api_client.create_reply_message(event)
      end
      @client_request.client.reply_message(event['replyToken'], @api_client.display_message)
    end
    head :ok
  end

  private

  def create_schedule
    if @api_client.create_schedule(event)
      @api_client.create_complete_message(event)
    else
      @api_client.create_fail_message(event)
    end
  end

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
        message = create_default_delete_message(event)
      when /削除/
        if delete_schedule(event)
          message = create_deleted_message(event)
        else
          message = {
            type: 'text',
            text: '削除に失敗しました'
          }
        end
      end
    end
    message
  end

  def create_default_message
    text = <<~DEFAULT_MESSAGE
      ■タイトルとカテゴリを入力してください
      ■カテゴリ：「一日だけ」・「毎日」・「毎週」・「毎月」
      ----例----
      毎日
      海水浴
    DEFAULT_MESSAGE
    message = {
      type: 'text',
      text: text
    }
    message
  end

  def create_default_delete_message(event)
    talk_room_type_id = TalkRoomType.find_by(type_name: event['source']['type']).id
    target_id_type = TalkRoomType.find_by(id: talk_room_type_id).target_id_type
    talk_room_id = event['source'][target_id_type]
    target_list = Schedule.where(
      talk_room_type_id: talk_room_type_id,
      talk_room_id: talk_room_id,
      deleted: false
    ).where.not(
      schedule_type: Schedule.schedule_types[:specific_day], sent: true
    ).pluck(
      :id,
      :title
    )
    text = <<~DELETE_DEFAULT_MESSAGE
      ■削除するスケジュールのIDを入力してください
      ■予定一覧：#{target_list.map { |id, title| id.to_s + '.' + title }.join', '}
      ----例----
      削除
      1
    DELETE_DEFAULT_MESSAGE
    message = {
      type: 'text',
      text: text
    }
    message
  end

  def delete_schedule(event)
    schedule_id = event.message['text'].delete("\n削除")
    target_schedule = Schedule.find_by_id(schedule_id)
    return nil if target_schedule.nil?
    target_schedule.update_attribute(:deleted, true)
  end

  def create_deleted_message(event)
    schedule_id = event.message['text'].delete("\n削除")
    message = {
      type: 'text',
      text: "ID:#{schedule_id}を削除しました"
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
