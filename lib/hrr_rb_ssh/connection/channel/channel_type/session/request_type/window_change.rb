# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class WindowChange < RequestType
              NAME = 'window-change'

              def self.run proc_chain, username, io, variables, message, options
                logger = Logger.new self.class.name

                context = Context.new proc_chain, username, io, variables, message
                handler = options.fetch('connection_channel_request_window_change', RequestHandler.new {})
                handler.run context

                proc_chain.connect context.chain_proc
              end
            end
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/window_change/context'
