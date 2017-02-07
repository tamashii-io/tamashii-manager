require "codeme/manager/errors/authorization_error"
require "codeme/manager/config"

module Codeme
  module Manager
    module Authorizator
      class Token
        attr_reader :client_id

        def initialize
          @client_id = nil
          @authorized = false
          @type = Type::CLIENT[:agent]
        end

        def verify!(data)
          @type, @client_id, token = data.split(",")
          Manager.logger.debug("Client #{@client_id} try to verify token: #{Config.env.production? ? "FILTERED" : token}")
          raise AuthorizationError.new("Token mismatch!") unless @authorized = Config.token == token
          raise AuthorizationError.new("Device type not available!") unless Type::CLIENT.values.include?(@type.to_i)
          [@type.to_i, @client_id]
        end
      end
    end
  end
end
