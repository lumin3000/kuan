class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UrlHelper

  def pagination_default
    { page: params[:page] || 1,  per_page: 10 }
  end
  
  def business_config
    YAML.load_file "#{Rails.root}/config/business.yml"
  end
end
