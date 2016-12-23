require "codeme/manager/version"
require "codeme/manager/config"
require "codeme/manager/authorization"
require "codeme/common"

Codeme::Resolver.handle Codeme::Type::AUTH_TOKEN, Codeme::Manager::Authorization

module Codeme
  module Manager
    def self.config(&block)
      return Config.class_eval(&block) if block_given?
      Config
    end

    def self.logger
      @logger ||= Codeme::Logger.new(Config.log_file)
    end
  end
end
