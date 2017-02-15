module Tamashi
  module Manager
    class Connection < Set
      class << self
        def instance
          @instance ||= Connection.new
        end

        def register(client)
          instance.add(client)
        end

        def unregister(client)
          instance.delete(client)
        end

        def available?
          !instance.empty?
        end
      end
    end
  end
end
