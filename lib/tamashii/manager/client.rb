require 'tamashii/manager/authorization'
require 'tamashii/common'

module Tamashii
  module Manager
    # :nodoc:
    class Client < Tamashii::Server::Connection::Base
      attr_reader :env, :url
      attr_reader :channel

      attr_reader :last_beat_timestamp
      attr_reader :last_response_time

      attr_accessor :tag

      def self.accepted_clients
        Clients.instance
      end

      def id
        return "<Unauthorized : #{@env['REMOTE_ADDR']}>" if @id.nil?
        @id
      end

      def type
        Type::CLIENT.key(@type)
      end

      def send(packet)
        packet = packet.dump if packet.is_a?(Tamashii::Packet)
        @socket.transmit(packet)
      end

      def authorized?
        !@id.nil?
      end

      def accept(type, id)
        @id = id
        @type = type
        @channel = Channel.subscribe(self)
        Clients.register(self)
        send(Tamashii::Packet.new(Tamashii::Type::AUTH_RESPONSE, @channel.id, true).dump)
      end

      def on_open
        Manager.logger.info("Client #{id} is ready")
      end

      def on_message(data)
        Manager.logger.debug("Receive Data: #{data}")
        return unless data.is_a?(Array)
        Tamashii::Resolver.resolve(Tamashii::Packet.load(data), client: self)
      rescue AuthorizationError => e
        Manager.logger.error("Client #{id} authentication failed => #{e.message}")
        send(Tamashii::Packet.new(Tamashii::Type::AUTH_RESPONSE, 0, false))
        @socket.close
      rescue => e
        Manager.logger.error("Error when receiving data from client #{id}: #{e.message}")
        Manager.logger.debug("Backtrace:")
        e.backtrace.each {|msg| Manager.logger.debug(msg)}
      end

      def on_close(e)
        Manager.logger.info("Client #{id} closed connection")
      end

      def emit_error(message)
        Manager.logger.error("Client #{id} has error => #{message}")
      end
    end
  end
end
