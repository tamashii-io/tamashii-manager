# frozen_string_literal: true

require 'tamashii/common'
require 'tamashii/config'

module Tamashii
  module Manager
    # :nodoc:
    class Config
      class << self
        def instance
          @instance ||= Config.new
        end

        def respond_to_missing?(name, _all = false)
          super
        end

        def method_missing(name, *args, &block)
          # rubocop:disable Metrics/LineLength
          return instance.send(name, *args, &block) if instance.respond_to?(name)
          # rubocop:enable Metrics/LineLength
          super
        end
      end

      include Tamashii::Configurable

      AUTH_TYPES = %i[none token].freeze

      config :auth_type, default: :none
      config :token, default: nil
      config :log_file, default: STDOUT
      config :log_level, default: Logger::INFO
      config :env, default: nil
      config :heartbeat_interval, default: 3
      config :port, default: 3000

      def auth_type(type = nil)
        return self[:auth_type] if type.nil?
        return unless AUTH_TYPES.include?(type)
        self.auth_type = type
      end

      def log_level(level = nil)
        return Manager.logger.level if level.nil?
        self.log_level = level
      end

      # TODO: refactor this weird configuration
      # We need this because log_level is not a REAL existing variable
      def log_level=(level)
        Manager.logger.level = level
        # TODO: forwarding to server, or unify loggers
        Tamashii::Server.logger.level = level
      end

      def env(env = nil)
        return Tamashii::Environment.new(self[:env]) if env.nil?
        self.env = env.to_s
      end
    end
  end
end
