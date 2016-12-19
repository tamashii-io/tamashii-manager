require "codeme/manager/errors/authorization_error"
require "codeme/manager/authorizator/token"

module Codeme
  module Manager
    class Authorization
      module Type
        TOKEN = 010
        RESPONSE = 017
      end

      def initialize(type, raw_data)
        @authorize_method = from_authorizator_type(type)
        @raw_data = raw_data
      end

      def authorize!
        authorizator = @authorize_method.new
        authorizator.verify!(@raw_data)
        authorizator.client_id
      end

      private
      def from_authorizator_type(type)
        case type
        when Type::TOKEN
          Authorizator::Token
        else
          raise AuthorizationError.new("Invalid authorization type.")
        end
      end
    end
  end
end
