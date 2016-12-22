module Codeme
  module Manager
    class Config
      AUTH_TYPES = [:none, :token]
      APPLICATION_MODE = [:test, :development, :production]

      Env = Struct.new(:env) do
        def method_missing(name, *args, &block)
          name = name.to_s
          return unless APPLICATION_MODE.include?(name[0..-2].to_sym) && name[-1] == "?"
          (self[:env] || ENV['RACK_ENV'] || "development") == name[0..-2]
        end

        def ==(other)
          other.to_s == to_s
        end

        def inspect
          (self[:env] || ENV['RACK_ENV'] || "development")
        end

        def to_s
          (self[:env] || ENV['RACK_ENV'] || "development")
        end
      end

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
        return @log_file ||= STDOUT if @log_file || path.nil?
        @log_file = path.to_s
      end

      def log_level(level = nil)
        return Manager.logger.level if level.nil?
        Manager.logger.level = level
      end

      def env(env = nil)
        return Env.new(@env) if env.nil?
        @env = env.to_s
      end
    end
  end
end
