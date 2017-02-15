require "tamashi/manager/server"
require "tamashi/manager/version"
require "tamashi/manager/config"
require "tamashi/manager/authorization"
require "tamashi/manager/handler/broadcaster"
require "tamashi/manager/clients"
require "tamashi/common"

Tamashi::Resolver.default_handler Tamashi::Manager::Handler::Broadcaster
Tamashi::Resolver.handle Tamashi::Type::AUTH_TOKEN, Tamashi::Manager::Authorization

module Tamashi
  module Manager
    def self.config(&block)
      return Config.class_eval(&block) if block_given?
      Config
    end

    def self.logger
      @logger ||= Tamashi::Logger.new(Config.log_file)
    end
  end
end
