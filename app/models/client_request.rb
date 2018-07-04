class ClientRequest
  include ActiveModel::Model
  attr_reader :body, :signature, :client, :events

  def initialize(request)
    @body = request.body.read
    @signature = request.env['HTTP_X_LINE_SIGNATURE']
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
    @events = @client.parse_events_from(@body)
  end

  def validate_signature
    unless client.validate_signature(body, signature)
      error 400 do
        'Bad Request'
      end
    end
  end

  def execute
    p 'execute'
  end
end
