require 'line/bot'

class ApplicationController < ActionController::Base
  protect_from_forgery except: [:callback]

  before_action :validate_signature

  def validate_signature
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    @line = LineInterface.new
    unless @line.client.validate_signature(body, signature)
      error 400 do
        'Bad Request'
      end
    end
  end
end
