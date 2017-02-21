require "tamashii/manager/errors/authorization_error"
require "tamashii/manager/authorizator/token"
require "tamashii/common"

module Tamashii
  module Manager
    class Authorization < Tamashii::Handler
      def resolve(data = nil)
        type, client_id = case @type
                          when Tamashii::Type::AUTH_TOKEN
                            Authorizator::Token.new.verify!(data)
                          else
                            raise AuthorizationError.new("Invalid authorization type.")
                          end
        @env[:client].accept(type, client_id)
      end
    end
  end
end
