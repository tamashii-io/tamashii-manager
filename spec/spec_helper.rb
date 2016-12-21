$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "codeme/manager"
require "codeme/rspec/helpers"

require 'rack/test'
require 'simplecov'

SimpleCov.start


RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include Codeme::RSpec::Helpers
end

Codeme::Manager.config do
  log_file Tempfile.new.path
end
