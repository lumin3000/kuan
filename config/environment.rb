# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Kuan::Application.initialize!

Haml::Template.options[:format] = :xhtml
