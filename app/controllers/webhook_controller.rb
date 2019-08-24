class WebhookController < ApplicationController

  def callback
    @api_client = LineApiClient.new
    @api_client.set_events(request)
    @api_client.events.each do |event|
      message = @api_client.analyze_event(event)
      @api_client.reply_message(event['replyToken'], message)
    end
    head :ok
  end
end
