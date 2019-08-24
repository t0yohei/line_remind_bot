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

  #
  # webhook で送られてくるイベントの解析を実行する処理
  # 解析の詳細は、 LineApiClient::EventAnalyzer クラスに任せる
  # @return [Array] :replying_messages ReplyingMessage クラスのインスタンスの配列
  #
  def analayze_events
    return LineApiClient::EventAnalyzer.new(events).perform
  end

  #
  # replying_messages オブジェクトを元にリプライを送る
  # @params [Array] :replying_messages ReplyingMessage クラスのインスタンスの配列
  #
  def reply_messages(replying_messages)
    replying_messages.each do |replying_message|
      reply_message(replying_message.reply_token, replying_message.message)
    end
  end

  # Line API クライアントの reqlay_message メソッドをラップする
  def reply_message(reply_token, message)
    client.reply_message(reply_token, message)
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
end
