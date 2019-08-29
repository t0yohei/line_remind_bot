class LineApiClient::MessageFactory::CompleteMessageBuilder
  attr_reader :message_type, :postback_params

  def initialize(postback_params)
    @postback_params = postback_params
    @message_type = @postback_params.first.first
  end

  def build
    case message_type
    when /datetime/
      get_datetime_complete_message
    when /time/
      get_time_complete_message
    end
  end

  private

  def get_datetime_complete_message
    {
      type: 'text',
      text: postback_params['datetime'] + ' が入力されました'
    }
  end

  def get_time_complete_message
    {
      type: 'text',
      text: postback_params['time'] + ' が入力されました'
    }
  end
end