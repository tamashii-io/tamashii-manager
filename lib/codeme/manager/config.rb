module Codeme
  module Manager
    class Config
      AUTH_TYPES = [:none, :token]

      class << self
        def instance
          @instance ||= Config.new
        end

        def method_missing(name, *args, &block)
          instance.send(name, *args, &block)
        end
      end

      def auth_type(type = nil)
        return @auth_type ||= :none if type.nil?
        return unless AUTH_TYPES.include?(type)
        @auth_type = type.to_sym
      end

      def token(token = nil)
        return @token if token.nil?
        @token = token.to_s
      end

      def log_file(path = nil)
        return @log_file ||= STDOUT if path.nil?
        @log_file = path.to_s
      end

      def log_level(level = nil)
        return Logger.level if level.nil?
        Logger.level = level
      end
    end
  end
end
