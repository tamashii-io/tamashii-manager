require "codeme/manager/version"
require "codeme/manager/configuration"

module Codeme
  module Manager
    def self.config(&block)
      return Config.class_eval(&block) if block_given?
      Config
    end
  end
end
