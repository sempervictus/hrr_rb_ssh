# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'
require 'hrr_rb_ssh/connection/channel/session/exec/context'

module HrrRbSsh
  class Connection
    class Channel
      module Session
        request_type = 'exec'

        class Exec
          def self.run proc_chain, username, io, variables, message, options
            logger = HrrRbSsh::Logger.new self.class.name

            context = Context.new proc_chain, username, io, variables, message
            handler = options.fetch('connection_channel_request_exec', RequestHandler.new {})
            handler.run context

            proc_chain.connect context.chain_proc
          end
        end

        @@request_type_list ||= Hash.new
        @@request_type_list[request_type] = Exec
      end
    end
  end
end
