$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rack/test'
require 'simplecov'

SimpleCov.start

require "tamashii/manager"
require "tamashii/rspec/helpers"

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include Tamashii::RSpec::Helpers
end

Tamashii::Manager.config do
  log_file Tempfile.new.path
end


