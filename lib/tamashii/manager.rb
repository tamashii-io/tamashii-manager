# frozen_string_literal: true

require 'tamashii/server'
require 'tamashii/manager/version'
require 'tamashii/manager/handler/broadcaster'

module Tamashii
  # :nodoc:
  module Manager
    autoload :Server,        'tamashii/manager/server'
    autoload :Config,        'tamashii/manager/config'
    autoload :Client,        'tamashii/manager/client'
    autoload :Channel,       'tamashii/manager/channel'
    autoload :Authorization, 'tamashii/manager/authorization'

    def self.config(&block)
      return instance_exec(Config.instance, &block) if block_given?
      Config
    end

    def self.logger
      @logger ||= ::Logger.new(config.log_file)
    end
  end
end

# TODO: Use block mode to define resolver
# rubocop:disable Metrics/LineLength
Tamashii::Resolver.default_handler Tamashii::Manager::Handler::Broadcaster
Tamashii::Resolver.handle Tamashii::Type::AUTH_TOKEN, Tamashii::Manager::Authorization
# rubocop:enable Metrics/LineLength
