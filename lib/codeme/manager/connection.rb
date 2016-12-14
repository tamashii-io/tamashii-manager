module Codeme
  module Manager
    class Connection
      class << self
        def register(client)
          @connections ||= []
          @connections << client
        end

        def unregister(client)
          @connections.delete(client)
        end

        def available?
          @connections ||= []
          !@connections.empty?
        end
      end
    end
  end
end
