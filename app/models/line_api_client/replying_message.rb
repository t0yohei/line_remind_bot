class LineApiClient::ReplyingMessage
  attr_reader :reply_token, :message

  def initialize(reply_token:, message:)
    @reply_token = reply_token
    @message = message
  end
end