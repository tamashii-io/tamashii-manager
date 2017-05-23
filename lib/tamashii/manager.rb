require "tamashii/manager/server"
require "tamashii/manager/version"
require "tamashii/manager/config"
require "tamashii/manager/authorization"
require "tamashii/manager/handler/broadcaster"
require "tamashii/manager/clients"
require "tamashii/common"

Tamashii::Resolver.default_handler Tamashii::Manager::Handler::Broadcaster
Tamashii::Resolver.handle Tamashii::Type::AUTH_TOKEN, Tamashii::Manager::Authorization

module Tamashii
  module Manager
    def self.config(&block)
      return Config.class_eval(&block) if block_given?
      Config
    end

    def self.logger
      @logger ||= ::Logger.new(Config.log_file)
    end
  end
end
