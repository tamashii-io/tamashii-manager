require "nio"

require "codeme/manager/connection"

Thread.abort_on_exception = true

module Codeme
  module Manager
    class Stream
      def initialize(event_loop, io, client)
        @client = client
        event_loop.attach(io, self)
      end

      def receive(data)
        @client.parse(data)
      end

      def close
      end
    end
  end
end
