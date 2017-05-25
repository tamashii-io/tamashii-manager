# frozen_string_literal: true

module Tamashii
  module Manager
    # :nodoc:
    class Authorization < Tamashii::Handler
      def resolve(data = nil)
        type, client_id = case @type
                          when Tamashii::Type::AUTH_TOKEN
                            Authorizator::Token.new.verify!(data)
                          else
                            raise Error::AuthorizationError,
                                  'Invalid authorization type.'
                          end
        @env[:client].accept(type, client_id)
      end
    end
  end
end
