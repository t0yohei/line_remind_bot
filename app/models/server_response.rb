class ServerResponse
  include ActiveModel::Model
  attr_reader :client, :message

  def initialize
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def create_message(events)
    events.each do |event|
    end
  end

  def send_message
    p 'message'
  end
end
