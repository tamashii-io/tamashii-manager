require 'tamashii/server'
require 'tamashii/manager/version'
require 'tamashii/manager/authorization'
require 'tamashii/manager/handler/broadcaster'
require 'tamashii/manager/clients'
require 'tamashii/common'

# TODO: Use block mode to define resolver
# rubocop:disable Metrics/LineLength
Tamashii::Resolver.default_handler Tamashii::Manager::Handler::Broadcaster
Tamashii::Resolver.handle Tamashii::Type::AUTH_TOKEN, Tamashii::Manager::Authorization
# rubocop:enable Metrics/LineLength

module Tamashii
  # :nodoc:
  module Manager
    autoload :Server, 'tamashii/manager/server'
    autoload :Config, 'tamashii/manager/config'
    autoload :Client, 'tamashii/manager/client'

    def self.config(&block)
      return Config.class_eval(&block) if block_given?
      Config
    end

    def self.logger
      @logger ||= ::Logger.new(Config.log_file)
    end
  end
end
