$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "codeme/manager"
require 'rack/test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

Codeme::Manager.config do
  log_file Tempfile.new.path
end
