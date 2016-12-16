module Codeme
  module Manager
    module Config
      AUTH_TYPES = [:none, :token]

      def self.auth_type(type = nil)
        return @auth_type ||= :none if type.nil?
        return unless AUTH_TYPES.include?(type)
        @auth_type = type.to_sym
      end

      def self.token(token = nil)
        return @token if token.nil?
        @token = token.to_s
      end

      def self.log_file(path = nil)
        return @log_file ||= STDOUT if path.nil?
        @log_file = path.to_s
      end
    end
  end
end
