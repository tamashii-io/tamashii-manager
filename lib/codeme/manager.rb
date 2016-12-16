require "codeme/manager/version"
require "codeme/manager/configuration"
require "codeme/manager/logger"

module Codeme
  module Manager
    def self.config(&block)
      return Config.class_eval(&block) if block_given?
      Config
    end

    def self.logger
      @logger ||= Logger.new(Config.log_file)
    end
  end
end
