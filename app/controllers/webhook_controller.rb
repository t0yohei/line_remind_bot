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
          message = {
            type: 'text',
            text: '入力されました'
          }
        # case event['postback']['params']
        # when Line::Bot::Event::Postback::Params::Datetime
        #   message = {
        #     type: 'text',
        #     text: event['postback']['params']['datetime'] + 'が入力されました'
        #   }
        # when Line::Bot::Event::Postback::Params::Time
        #   message = {
        #     type: 'text',
        #     text: event['postback']['params']['time'] + 'が入力されました'
        #   }
        # end
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          input_text = event.message['text']
          case input_text
          when '一日だけ'
            message = {
              type: 'template',
              altText: 'this is an template message',
              template: {
                type: 'buttons',
                title: '一日だけ',
                text: '日時を指定',
                actions: [
                  {
                    type: 'datetimepicker',
                    label: '日時を指定',
                    data: '一日だけ',
                    mode: 'datetime',
                  },
                ]
              }
            }
          when '毎日'
            message = {
              type: 'template',
              altText: 'this is an template message',
              template: {
                type: 'buttons',
                title: '毎日',
                text: '時間を指定',
                actions: [
                  {
                    type: 'datetimepicker',
                    label: '時間を指定',
                    data: '毎日',
                    mode: 'time',
                  },
                ]
              }
            }
          when '毎週'
            message = {
              type: 'template',
              altText: 'this is an template message',
              template: {
                type: 'buttons',
                title: '曜日選択',
                # thumbnailImageUrl: 'https://example.com/image.jpg',
                text: '曜日を選択してください',
                actions: [
                  {
                    type: 'message',
                    label: '月曜日',
                    text: '月曜日'
                  },
                  {
                    type: 'message',
                    label: '火曜日',
                    text: '火曜日'
                  },
                  {
                    type: 'message',
                    label: '水曜日',
                    text: '水曜日'
                  },
                  {
                    type: 'message',
                    label: 'その他の曜日',
                    text: 'その他の曜日'
                  },
                ]
              }
            }
          when 'その他の曜日'
            message = {
              type: 'template',
              altText: 'this is an template message',
              template: {
                type: 'buttons',
                title: '曜日選択',
                # thumbnailImageUrl: 'https://example.com/image.jpg',
                text: '曜日を選択してください',
                actions: [
                  {
                    type: 'message',
                    label: '木曜日',
                    text: '木曜日'
                  },
                  {
                    type: 'message',
                    label: '金曜日',
                    text: '金曜日'
                  },
                  {
                    type: 'message',
                    label: '土曜日',
                    text: '土曜日'
                  },
                  {
                    type: 'message',
                    label: '日曜日',
                    text: '日曜日'
                  },
                ]
              }
            }
          when '毎月'
            message = {
              type: 'template',
              altText: 'this is an template message',
              template: {
                type: 'buttons',
                title: '毎月',
                text: '日時を指定',
                actions: [
                  {
                    type: 'datetimepicker',
                    label: '日時を指定',
                    data: '毎月',
                    mode: 'datetime',
                  },
                ]
              }
            }
          else
            message = {
              type: 'text',
              text: event.message['text'] + 'が入力されました'
            }
          end
        end
      end
      client.reply_message(event['replyToken'], message)
    }

    head :ok
  end
end
