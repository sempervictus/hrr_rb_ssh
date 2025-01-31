# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class RequestHandler
      def initialize &block
        @logger = Logger.new self.class.name
        @proc = block
      end
      def run context
        @proc.call context
      end
    end
  end
end

require 'hrr_rb_ssh/connection/request_handler/reference_pty_req_request_handler'
require 'hrr_rb_ssh/connection/request_handler/reference_env_request_handler'
require 'hrr_rb_ssh/connection/request_handler/reference_shell_request_handler'
require 'hrr_rb_ssh/connection/request_handler/reference_exec_request_handler'
require 'hrr_rb_ssh/connection/request_handler/reference_window_change_request_handler'
