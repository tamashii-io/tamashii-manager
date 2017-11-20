# frozen_string_literal: true

require 'tamashii/server'
require 'tamashii/common'
require 'tamashii/hookable'
require 'tamashii/manager/version'

require 'tamashii/manager/subscription'
require 'tamashii/manager/config'
require 'tamashii/manager/client_manager'
require 'tamashii/manager/client'
require 'tamashii/manager/channel'
require 'tamashii/manager/channel_pool'
require 'tamashii/manager/authorization'
require 'tamashii/manager/authorizator'
require 'tamashii/manager/handler'
require 'tamashii/manager/error'
require 'tamashii/manager/server'

module Tamashii
  # :nodoc:
  module Manager
    def self.config(&block)
      return instance_exec(Config.instance, &block) if block_given?
      Config
    end

    def self.logger
      @logger ||= ::Logger.new(config.log_file)
    end

    def self.server
      @server ||= Tamashii::Manager::Server.new
    end
  end
end

# TODO: Use block mode to define resolver
# rubocop:disable Metrics/LineLength
Tamashii::Resolver.default_handler Tamashii::Manager::Handler::Broadcaster
Tamashii::Resolver.handle Tamashii::Type::AUTH_TOKEN, Tamashii::Manager::Authorization
# rubocop:enable Metrics/LineLength

Tamashii::Hook.after(:config) do |config|
  config.register(:manager, Tamashii::Manager.config)
end
