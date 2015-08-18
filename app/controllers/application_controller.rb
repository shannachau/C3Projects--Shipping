require 'httparty'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ORIGIN = { country: 'US', state: 'WA', city: 'Seattle', zip: '98101' }

end
