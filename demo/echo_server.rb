# coding: utf-8
# vim: et ts=2 sw=2

require 'logger'
require 'socket'

def start_service io, logger=nil
  begin
    require 'hrr_rb_ssh'
  rescue LoadError
    $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
    require 'hrr_rb_ssh'
  end

  HrrRbSsh::Logger.initialize logger if logger

  auth_password = HrrRbSsh::Authentication::Authenticator.new { |context|
    true # accept any user and password
  }

  conn_echo = HrrRbSsh::Connection::RequestHandler.new { |context|
    context.chain_proc { |chain|
      begin
        loop do
          buf = context.io[0].readpartial(10240)
          break if buf.include?(0x04.chr) # break if ^D
          context.io[1].write buf
        end
        exitstatus = 0
      rescue => e
        logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
        exitstatus = 1
      end
      exitstatus
    }
  }

  options = {}
  options['authentication_password_authenticator'] = auth_password
  options['connection_channel_request_shell']      = conn_echo

  server = HrrRbSsh::Server.new options
  server.start io
end

logger = Logger.new STDOUT
logger.level = Logger::INFO

server = TCPServer.new 10022
loop do
  Thread.new(server.accept) do |io|
    begin
      pid = fork do
        begin
          start_service io, logger
        rescue => e
          logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
          exit false
        end
      end
      logger.info { "process #{pid} started" }
      io.close rescue nil
      pid, status = Process.waitpid2 pid
    rescue => e
      logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
    ensure
      status ||= nil
      logger.info { "process #{pid} finished with status #{status.inspect}" }
    end
  end
end
