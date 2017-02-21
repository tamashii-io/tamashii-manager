module Tamashii
  module Manager
    class Clients < Hash
      class << self
        def method_missing(name, *args, &block)
          self.instance.send(name, *args, &block)
        end

        def instance
          @instance ||= new
        end
      end

      def register(client)
        self[client.id] = client
      end

      def unregister(client)
        self.delete(client.id)
      end
    end
  end
end
