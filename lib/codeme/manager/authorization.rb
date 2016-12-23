require "codeme/manager/errors/authorization_error"
require "codeme/manager/authorizator/token"
require "codeme/common"

module Codeme
  module Manager
    class Authorization < Codeme::Handler
      def resolve(data = nil)
        client_id = case @type
                    when Codeme::Type::AUTH_TOKEN
                      Authorizator::Token.new.verify!(data)
                    else
                      raise AuthorizationError.new("Invalid authorization type.")
                    end
        @env[:client].accept(client_id)
      end
    end
  end
end
