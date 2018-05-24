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
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          input_text = event.message['text']
          if input_text == '一日だけ'
            message = {
              type: 'text',
              text: '日付を入力してください'
            }
          elsif input_text == '毎週'
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
                    label: '木曜日',
                    text: '木曜日'
                  },
                  # {
                  #   type: 'message',
                  #   label: '金曜日',
                  #   text: '金曜日'
                  # },
                  # {
                  #   type: 'message',
                  #   label: '土曜日',
                  #   text: '土曜日'
                  # },
                  # {
                  #   type: 'message',
                  #   label: '日曜日',
                  #   text: '日曜日'
                  # },
                ]
              }
            }
          else
            message = {
              type: 'text',
              text: event.message['text'] + '正しく入力してください'
            }
          end
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
