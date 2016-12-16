require "websocket/driver"
require "nio"

require "codeme/manager/stream"
require "codeme/manager/channel"
require "codeme/common"

module Codeme
  module Manager
    class Client
      attr_reader :env, :url
      attr_accessor :tag

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

        # TODO: Move to auth stage to do this
        @channel = Channel.subscribe(self)

        @driver.on(:open)    { |e| open }
        @driver.on(:message) { |e| receive(e.data) }
        @driver.on(:close)   { |e| close(e) }
        @driver.on(:error)   { |e| emit_error(e.message) }

        Logger.info("Accept connection from #{env['REMOTE_ADDR']}")

        @driver.start
      end

      def write(buffer)
        @io.write(buffer)
      end

      def send(packet)
        @driver.binary(packet)
      end

      def parse(buffer)
        @driver.parse(buffer)
      end

      private
      def open
        Logger.info("Client #{@env['REMOTE_ADDR']} is ready")
      end

      def receive(data)
        Logger.debug("Receive Data: #{data}")
        Channel.get(@tag).broadcast(data)
      end

      def close(e)
        Logger.info("Client #{@env['REMOTE_ADDR']} closed connection")
        Connection.unregister(self)
        Channel.unsubscribe(self)
        @stream.close
      end

      def emit_error(message)
        Logger.error("Client #{@env['REMOTE_ADDR']} has error => #{message}")
      end
    end
  end
end
