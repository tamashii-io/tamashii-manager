# frozen_string_literal: true

require 'tamashii/common'
require 'tamashii/configurable'

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
          return instance.send(name, *args, &block) if instance.class.exist?(name)
          # rubocop:enable Metrics/LineLength
          super
        end
      end

      include Tamashii::Configurable

      AUTH_TYPES = %i[none token].freeze

      register :auth_type, :none
      register :token, nil
      register :log_file, STDOUT
      register :log_level, Logger::INFO
      register :env, nil
      register :heartbeat_interval, 3
      register :port, 3000

      def [](key)
        config(key)
      end

      def []=(key, value)
        config(key, value)
      end

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
