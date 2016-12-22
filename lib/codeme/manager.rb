require "codeme/manager/version"
require "codeme/manager/config"
require "codeme/common"

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
