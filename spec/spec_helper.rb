$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rack/test'
require 'simplecov'

SimpleCov.start

require "codeme/manager"
require "codeme/rspec/helpers"

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include Codeme::RSpec::Helpers
end

Codeme::Manager.config do
  log_file Tempfile.new.path
end


