require "nio"

require "codeme/manager/connection"

Thread.abort_on_exception = true

module Codeme
  module Manager
    class Stream
      def initialize(event_loop, io, client)
        @client = client
        @io = io
        @event_loop = event_loop
        @event_loop.attach(io, self)
      end

      def receive(data)
        @client.parse(data)
      end

      def shutdown
        clean_rack_hijack
      end

      def close
        shutdown
        @client.shutdown
      end

      private
      def clean_rack_hijack
        return unless @io
        @event_loop.detach(@io, self)
        @io = nil
      end
    end
  end
end
