require 'line/bot'

class ApplicationController < ActionController::Base
  protect_from_forgery except: [:callback]

  def validate_signature
    @client_request = ClientRequest.new(request)
    @client_request.validate_signature
  end
end
