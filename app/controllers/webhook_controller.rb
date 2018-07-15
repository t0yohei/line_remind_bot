class WebhookController < ApplicationController
  before_action :validate_signature, only: :callback

  def callback
    events = @api_client.client.parse_events_from(request.body.read)
    events.each do |event|
      message = @api_client.analyze_event(event)
      @api_client.client.reply_message(event['replyToken'], message)
    end
    head :ok
  end
end
