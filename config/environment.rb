#allow files to read their private settings from settings.yml using SETTINGS
require 'yaml'
SETTINGS = YAML.load(IO.read(Rails.root.join("config", "settings.yml")))

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SettlersOfCatan::Application.initialize!
