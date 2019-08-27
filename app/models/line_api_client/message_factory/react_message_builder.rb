class LineApiClient::MessageFactory::ReactMessageBuilder
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def build
    input_text = event.message['text']
    case input_text
    when /\A(> )?予定を削除/
      LineApiClient::MessageFactory::ReactMessageFetcher.new(
        event
      ).build
    else
      LineApiClient::MessageFactory::ReactMessageGetter.new(
        input_text
      ).build
    end
  end
end