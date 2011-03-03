#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  require 'moving/mover'
  Mover.run
  sleep 1800
end
