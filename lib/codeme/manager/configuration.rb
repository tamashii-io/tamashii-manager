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
    end
  end
end
