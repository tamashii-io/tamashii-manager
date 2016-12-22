require 'codeme/common'

module Codeme
  module Manager
    class Config < Codeme::Config
      AUTH_TYPES = [:none, :token]

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
