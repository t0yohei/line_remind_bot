require 'line/bot'

class ApplicationController < ActionController::Base
  protect_from_forgery except: [:callback]
end
