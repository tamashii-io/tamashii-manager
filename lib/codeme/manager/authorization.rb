require "codeme/manager/errors/authorization_error"
require "codeme/manager/authorizator/token"

module Codeme
  module Manager
    class Authorization
      module TYPE
        TOKEN = 010
      end

      def initialize(type, raw_data)
        @authorize_method = from_authorizator_type(type)
        @raw_data = raw_data
      end

      def from_authorizator_type(type)
        case type
        when TYPE::TOKEN
          Authorizator::Token
        else
          raise AuthorizationError.new("Invalid authorization type.")
        end
      end

      def authorize!
        authoritor = @authorize_method.new
        if authoritor.verify(@raw_data)
          authoritor.client_id
        else
          raise AuthorizationError.new("Token mismatch.")
        end
      end
    end
  end
end
