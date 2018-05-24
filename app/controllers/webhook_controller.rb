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
