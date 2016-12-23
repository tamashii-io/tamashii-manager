require "websocket/driver"
require "nio"

require "codeme/manager/stream"
require "codeme/manager/channel"
require "codeme/manager/authorization"
require "codeme/common"

module Codeme
  module Manager
    class Client
      attr_reader :env, :url
      attr_accessor :tag

      def initialize(env, event_loop)
        @env = env
        @id = nil

        secure = Rack::Request.new(env).ssl?
        scheme = secure ? 'wss:' : 'ws:'
        @url = "#{scheme}//#{env['HTTP_HOST']}#{env['REQUEST_URI']}"

        Manager.logger.info("Accept connection from #{env['REMOTE_ADDR']}")

        @driver = WebSocket::Driver.rack(self)

        env['rack.hijack'].call
        @io = env['rack.hijack_io']

        Connection.register(self)
        @stream = Stream.new(event_loop, @io, self)

        @driver.on(:open)    { |e| open }
        @driver.on(:message) { |e| receive(e.data) }
        @driver.on(:close)   { |e| close(e) }
        @driver.on(:error)   { |e| emit_error(e.message) }

        @driver.start
      end

      def id
        return "<Unauthorized : #{@env['REMOTE_ADDR']}>" if @id.nil?
        @id
      end

      def write(buffer)
        @io.write(buffer)
      end

      def send(packet)
        packet = packet.dump if packet.is_a?(Codeme::Packet)
        @driver.binary(packet)
      end

      def parse(buffer)
        @driver.parse(buffer)
      end

      def authorized?
        !@id.nil?
      end

      def accept(id)
        @id = id
        @channel = Channel.subscribe(self)
        send(Codeme::Packet.new(Codeme::Type::AUTH_RESPONSE, @channel.id, true).dump)
      end

      private
      def open
        Manager.logger.info("Client #{id} is ready")
      end

      def receive(data)
        Manager.logger.info("Receive Data: #{data}")
        return unless data.is_a?(Array)
        return @channel.broadcast(data) if authorized?
        Codeme::Resolver.resolve(Codeme::Packet.load(data), client: self)
      rescue AuthorizationError => e
        Manager.logger.error("Client #{id} authentication failed => #{e.message}")
        send(Codeme::Packet.new(Codeme::Type::AUTH_RESPONSE, 0, false))
        @driver.close
      end

      def close(e)
        Manager.logger.info("Client #{id} closed connection")
        Connection.unregister(self)
        Channel.unsubscribe(self) if authorized?
        @stream.close
      end

      def emit_error(message)
        Manager.logger.error("Client #{id} has error => #{message}")
      end
    end
  end
end
