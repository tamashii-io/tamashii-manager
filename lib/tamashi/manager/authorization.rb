require "tamashi/manager/errors/authorization_error"
require "tamashi/manager/authorizator/token"
require "tamashi/common"

module Tamashi
  module Manager
    class Authorization < Tamashi::Handler
      def resolve(data = nil)
        type, client_id = case @type
                          when Tamashi::Type::AUTH_TOKEN
                            Authorizator::Token.new.verify!(data)
                          else
                            raise AuthorizationError.new("Invalid authorization type.")
                          end
        @env[:client].accept(type, client_id)
      end
    end
  end
end
