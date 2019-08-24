#
# webhook で送られてくるイベントの解析することが責務のクラス
#
class LineApiClient::EventAnalyzer
  attr_reader :events

  def initialize(events)
    @events = events
  end

  #
  # webhook で送られてくるイベントの解析を実行する処理
  # 解析の途中で DB への登録を行ったり、返答のためのメッセージを作成したりする
  # @return [Array] :replying_messages ReplyingMessage クラスのインスタンスの配列
  #
  def perform
    replying_messages = []
    events.each do |event|
      message = analyze_event(event)
      replying_messages.push(
        LineApiClient::ReplyingMessage.new(
          reply_token: event['replyToken'], message: message
          )
        )
    end
    return replying_messages
  end

  private

  #
  # event の内容を解析する
  # event の種類は postback, message が存在する
  #
  def analyze_event(event)
    case event
    when Line::Bot::Event::Postback
      analyze_postback(event)
    when Line::Bot::Event::Message
      analyze_message(event)
    end
  end

  def analyze_postback(event)
    if ScheduleRegister.create_schedule(event)
      MessageFactory.get_complete_message(event)
    else
      MessageFactory.get_fail_message(event)
    end
  end

  def analyze_message(event)
    if event.message['text'].to_s.start_with?('予定を削除')
      analyze_delete_message(event)
    else
      MessageFactory.get_react_message(event)
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