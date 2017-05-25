# frozen_string_literal: true

require 'tamashii/server'
require 'tamashii/common'
require 'tamashii/manager/version'

module Tamashii
  # :nodoc:
  module Manager
    autoload :Server,        'tamashii/manager/server'
    autoload :Config,        'tamashii/manager/config'
    autoload :Client,        'tamashii/manager/client'
    autoload :Channel,       'tamashii/manager/channel'
    autoload :ChannelPool,   'tamashii/manager/channel_pool'
    autoload :Authorization, 'tamashii/manager/authorization'
    autoload :Authorizator,  'tamashii/manager/authorizator'
    autoload :Handler,       'tamashii/manager/handler'
    autoload :Error,         'tamashii/manager/error'

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
