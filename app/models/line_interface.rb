class LineInterface
  include ActiveModel::Model
  attr_reader :client, :body, :events

  def initialize(body)
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
    @body = body
    @events = @client.parse_events_from(@body)
  end
end
