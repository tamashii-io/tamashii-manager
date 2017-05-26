# frozen_string_literal: true

module Tamashii
  module Manager
    # :nodoc:
    class Subscription < Tamashii::Server::Subscription::Redis
      def send_to(id, packet)
        packet = packet.dump if packet.is_a?(Tamashii::Packet)
        broadcast([id.bytesize, id.unpack('C*'), packet].flatten)
      end

      protected

      def process_message(message)
        operate = unpack(message)
        head_size = operate.take(1).first
        return if head_size.zero?
        target = operate.take(head_size + 1).drop(1)
        Client[target.pack('C*')]&.send(operate.drop(head_size + 1))
      end
    end
  end
end
