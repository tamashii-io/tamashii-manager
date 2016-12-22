require 'codeme/common'

module Codeme
  module Manager
    class Config < Codeme::Config
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

      register :auth_type, :none
      register :log_file, STDOUT

      def auth_type(type = nil)
        return self[:auth_type] if type.nil?
        return unless AUTH_TYPES.include?(type)
        self[:auth_type] = type
      end

      def log_level(level = nil)
        return Manager.logger.level if level.nil?
        Manager.logger.level = level
      end

    end
  end
end
