# frozen_string_literal: true

module Tamashii
  module Manager
    module Authorizator
      # :nodoc:
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
          raise Error::AuthorizationError, "Token mismatch!" unless @authorized = Config.token == token
          raise Error::AuthorizationError, "Device type not available!" unless Type::CLIENT.values.include?(@type.to_i)
          [@type.to_i, @client_id]
        end
      end
    end
  end
end
