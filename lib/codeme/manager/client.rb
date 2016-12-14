require "websocket/driver"
require "nio"

require "codeme/manager/stream"
require "codeme/common"

module Codeme
  module Manager
    class Client
      attr_reader :env, :url

      def initialize(env)
        @env = env

        secure = Rack::Request.new(env).ssl?
        scheme = secure ? 'wss:' : 'ws:'
        @url = "#{scheme}//#{env['HTTP_HOST']}#{env['REQUEST_URI']}"

        @driver = WebSocket::Driver.rack(self)

        env['rack.hijack'].call
        @io = env['rack.hijack_io']

        Connection.register(self)
        @stream = Stream.register(@io, self)

        @driver.on(:open)    { |e| open }
        @driver.on(:message) { |e| receive(e.data) }
        @driver.on(:close)   { |e| close(e) }
        @driver.on(:error)   { |e| emit_error(e.message) }

        @driver.start
      end

      def write(buffer)
        @io.write(buffer)
      end

      def parse(buffer)
        @driver.parse(buffer)
      end

      private
      def open
      end

      def receive(data)
        @driver.text(data)
      end

      def close(e)
        Connection.unregister(self)
        @stream.close
      end

      def emit_error(message)
      end
    end
  end
end
