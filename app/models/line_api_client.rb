#
# Line の API クライアントをラップするクラス
# Line の API クライアントと、 API を介して取得する eventを保持する。
#
class LineApiClient
  include ActiveModel::Model
  attr_reader :client
  attr_accessor :events

  def initialize
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def set_events(request)
    validate_signature(request)
    if events.blank?
      @events = client.parse_events_from(request.body.read)
    end
  end

  # Line API クライアントの reqlay_message メソッドをラップする
  def reply_message(event, message)
    client.reply_message(event['replyToken'], message)
  end

  def analyze_event(event)
    case event
    when Line::Bot::Event::Postback
      analyze_postback(event)
    when Line::Bot::Event::Message
      if event.message['text'].to_s.start_with?('予定を削除')
        analyze_delete_message(event)
      else
        MessageFactory.get_react_message(event)
      end
    end
  end

  private

  def validate_signature(request)
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do
        'Bad Request'
      end
    end
  end

  def analyze_postback(event)
    if ScheduleRegister.create_schedule(event)
      MessageFactory.get_complete_message(event)
    else
      MessageFactory.get_fail_message(event)
    end
  end

  def analyze_delete_message(event)
    if ScheduleRegister.delete_schedule(event)
      MessageFactory.get_delete_complete_message(event)
    else
      MessageFactory.get_delete_fail_message(event)
    end
  end
end
