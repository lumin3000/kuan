require 'rubygems'
require 'spork'

ENV["RAILS_ENV"] ||= 'test'

Spork.prefork do
  require 'rails/mongoid'
  Spork.trap_class_method Rails::Mongoid, :load_models

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
  end
end

Spork.each_run do
  require 'factory_girl_rails'

  Mongoid.master.collections.select do |collection|
    collection.name !~ /system/
  end.each(&:drop)
end
