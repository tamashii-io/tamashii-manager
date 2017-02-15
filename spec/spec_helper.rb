$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rack/test'
require 'simplecov'

SimpleCov.start

require "tamashi/manager"
require "tamashi/rspec/helpers"

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include Tamashi::RSpec::Helpers
end

Tamashi::Manager.config do
  log_file Tempfile.new.path
end


