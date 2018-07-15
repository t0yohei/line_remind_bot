require 'line/bot'

class ApplicationController < ActionController::Base
  protect_from_forgery except: [:callback]

  def validate_signature
    @api_client = LineApiClient.new
    @api_client.validate_signature(request)
  end
end
