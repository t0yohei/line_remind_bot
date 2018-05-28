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
        create_schedule(event)
        message = create_complete_message(event)
      when Line::Bot::Event::Message
        message = create_response_message(event)
      end
      client.reply_message(event['replyToken'], message)
    end
    head :ok
  end

  private

  def create_schedule(event)
    case event['postback']['data']
    when /一日だけ/
    when /毎日/
    when /毎週/
    when /毎月/

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
        # thumbnailImageUrl: 'https://example.com/image.jpg',
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
        # thumbnailImageUrl: 'https://example.com/image.jpg',
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
