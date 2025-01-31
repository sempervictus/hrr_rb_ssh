# coding: utf-8
# vim: et ts=2 sw=2

require 'socket'
require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class GlobalRequestHandler
      attr_reader \
        :accepted

      def initialize connection
        @logger = Logger.new self.class.name
        @connection = connection
        @tcpip_forward_servers = Hash.new
        @tcpip_forward_threads = Hash.new
      end

      def close
        @logger.info { "closing tcpip-forward" }
        @tcpip_forward_threads.values.each(&:exit)
        @tcpip_forward_servers.values.each{ |s|
          begin
            s.close
          rescue IOError # for compatibility for Ruby version < 2.3
            Thread.pass
          end
        }
        @tcpip_forward_threads.clear
        @tcpip_forward_servers.clear
        @logger.info { "tcpip-forward closed" }
      end

      def request message
        case message[:'request name']
        when "tcpip-forward"
          tcpip_forward message
        when "cancel-tcpip-forward"
          cancel_tcpip_forward message
        else
          @logger.warn { "unsupported request name: #{message[:'request name']}" }
          raise
        end
      end

      def tcpip_forward message
        @logger.info { "starting tcpip-forward" }
        begin
          address_to_bind     = message[:'address to bind']
          port_number_to_bind = message[:'port number to bind']
          id = "#{address_to_bind}:#{port_number_to_bind}"
          server = TCPServer.new address_to_bind, port_number_to_bind
          @tcpip_forward_servers[id] = server
          @tcpip_forward_threads[id] = Thread.new(server){ |server|
            begin
              loop do
                Thread.new(server.accept){ |s|
                  @connection.channel_open_start address_to_bind, port_number_to_bind, s
                }
              end
            rescue => e
              @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
            end
          }
          @logger.info { "tcpip-forward started" }
        rescue => e
          @logger.warn { "starting tcpip-forward failed: #{e.message}" }
          raise e
        end
      end

      def cancel_tcpip_forward message
        @logger.info { "canceling tcpip-forward" }
        address_to_bind     = message[:'address to bind']
        port_number_to_bind = message[:'port number to bind']
        id = "#{address_to_bind}:#{port_number_to_bind}"
        @tcpip_forward_threads[id].exit
        begin
          @tcpip_forward_servers[id].close
        rescue IOError # for compatibility for Ruby version < 2.3
          Thread.pass
        end
        @tcpip_forward_threads.delete id
        @tcpip_forward_servers.delete id
        @logger.info { "tcpip-forward canceled" }
      end
    end
  end
end
