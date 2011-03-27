class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UrlHelper

  def business_config
    YAML.load_file "#{Rails.root}/config/business.yml"
  end
end
