class WebhookController < ApplicationController
  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Postback
        case event['postback']['params'].first.first
        when /datetime/
          message = {
            type: 'text',
            text: event['postback']['params']['datetime'] + 'が入力されました'
          }
        when /time/
          message = {
            type: 'text',
            text: event['postback']['params']['time'] + 'が入力されました'
          }
        end
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          input_text = event.message['text']
          case input_text
          when '予定を登録'
            message = {
              type: 'text',
              text: 'タイトルとカテゴリを入力してください' \
              "\nカテゴリ：「一日だけ」・「毎日」・「毎週」・「毎月」\n例：\n海水浴\n毎日"
            }
          when /一日だけ/
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
          when /毎日/
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
          when /毎週/ && /曜日/
            message = {
              type: 'text',
              text: event.message['text'] + '入力されました'
            }
          when /毎週/ && /その他/
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
          when /毎週/
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
          when /毎月/
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
          else
            message = {
              type: 'text',
              text: 'タイトル：' + event.message['text'] + '「毎日」'
            }
          end
        end
      end
      client.reply_message(event['replyToken'], message)
    }

    head :ok
  end
end
