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

      def initialize(env)
        @env = env
        @id = nil

        secure = Rack::Request.new(env).ssl?
        scheme = secure ? 'wss:' : 'ws:'
        @url = "#{scheme}//#{env['HTTP_HOST']}#{env['REQUEST_URI']}"

        Logger.info("Accept connection from #{env['REMOTE_ADDR']}")

        @driver = WebSocket::Driver.rack(self)

        env['rack.hijack'].call
        @io = env['rack.hijack_io']

        Connection.register(self)
        @stream = Stream.register(@io, self)

        # TODO: Move to auth stage to do this

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
        @driver.binary(packet)
      end

      def parse(buffer)
        @driver.parse(buffer)
      end

      def authorized?
        !@id.nil?
      end

      private
      def open
        Logger.info("Client #{@id} is ready")
      end

      def receive(data)
        Logger.debug("Receive Data: #{data}")
        return unless data.is_a?(Array)

        if authorized?
          @channel.broadcast(data)
        else
          verify_client(data)
        end
      end

      def close(e)
        Logger.info("Client #{@id} closed connection")
        Connection.unregister(self)
        Channel.unsubscribe(self)
        @stream.close
      end

      def emit_error(message)
        Logger.error("Client #{@id} has error => #{message}")
      end

      def verify_client(data)
        packet = Codeme::Packet.load(data)
        @id = Authorization.new(packet.type, packet.body).authorize!
        @channel = Channel.subscribe(self) if authorized?
        send(Codeme::Packet.new(Authorization::TYPE::RESPONSE, @channel.id, @channel.id.to_s).dump)
      rescue AuthorizationError => e
        Logger.error("Client #{@id} authentication failed => #{e.message}")
        @driver.close
      end
    end
  end
end
