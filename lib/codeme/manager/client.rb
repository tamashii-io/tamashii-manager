require "websocket/driver"
require "codeme/manager/stream"
require "codeme/manager/channel"
require "codeme/manager/authorization"
require "codeme/common"

module Codeme
  module Manager
    class Client

      attr_reader :env, :url
      attr_reader :channel

      attr_reader :last_beat_timestamp
      attr_reader :last_response_time

      attr_accessor :tag

      def initialize(env, event_loop)
        @env = env
        @id = nil
        @type = Type::CLIENT[:agent]
        @last_beat_timestamp = Time.at(0)
        @last_response_time = Float::INFINITY

        secure = Rack::Request.new(env).ssl?
        scheme = secure ? 'wss:' : 'ws:'
        @url = "#{scheme}//#{env['HTTP_HOST']}#{env['REQUEST_URI']}"

        Manager.logger.info("Accept connection from #{env['REMOTE_ADDR']}")

        @driver = WebSocket::Driver.rack(self)

        env['rack.hijack'].call
        @io = env['rack.hijack_io']

        Connection.register(self)
        @stream = Stream.new(event_loop, @io, self)

        @driver.on(:open)    { |e| on_open }
        @driver.on(:message) { |e| receive(e.data) }
        @driver.on(:close)   { |e| on_close(e) }
        @driver.on(:error)   { |e| emit_error(e.message) }

        @driver.start
      end

      def id
        return "<Unauthorized : #{@env['REMOTE_ADDR']}>" if @id.nil?
        @id
      end

      def type
        Type::CLIENT.key(@type)
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

      def accept(type, id)
        @id = id
        @type = type
        @channel = Channel.subscribe(self)
        send(Codeme::Packet.new(Codeme::Type::AUTH_RESPONSE, @channel.id, true).dump)
      end

      def close
        @driver.close
      end

      def shutdown
        Connection.unregister(self)
        Channel.unsubscribe(self) if authorized?
      end
      
      def beat
        beat_time = Time.now
        @driver.ping("heart-beat-at-#{beat_time}") do
          heartbeat_callback(beat_time)
        end
      end

      def heartbeat_callback(beat_time)
        @last_beat_timestamp = Time.now
        @last_response_time = @last_beat_timestamp - beat_time
        Manager.logger.debug "Heart beat #{beat_time} returns at #{@last_beat_timestamp}! Delay: #{(@last_response_time * 1000).round} ms" 
      end

      private
      def on_open
        Manager.logger.info("Client #{id} is ready")
      end

      def receive(data)
        Manager.logger.debug("Receive Data: #{data}")
        return unless data.is_a?(Array)
        Codeme::Resolver.resolve(Codeme::Packet.load(data), client: self)
      rescue AuthorizationError => e
        Manager.logger.error("Client #{id} authentication failed => #{e.message}")
        send(Codeme::Packet.new(Codeme::Type::AUTH_RESPONSE, 0, false))
        @driver.close
      rescue => e
        Manager.logger.error("Error when receiving data from client #{id}: #{e.message}")
        Manager.logger.debug("Backtrace:")
        e.backtrace.each {|msg| Manager.logger.debug(msg)}
      end

      def on_close(e)
        Manager.logger.info("Client #{id} closed connection")
        @stream.close
      end

      def emit_error(message)
        Manager.logger.error("Client #{id} has error => #{message}")
      end
    end
  end
end
