class WebhookController < ApplicationController

  def callback
    @api_client = LineApiClient.new
    @api_client.set_events(request)
    replying_messages = @api_client.analayze_events
    @api_client.reply_messages(replying_messages)

    # リクエストもとの Webhook には必ず 200 を返す必要がある。
    head :ok
  end
end
