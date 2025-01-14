# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message'

module HrrRbSsh
  class Authentication
    class Method
      class KeyboardInteractive
        class InfoRequest
          def initialize name, instruction, language_tag, prompts
            @name         = name
            @instruction  = instruction
            @language_tag = language_tag
            @prompts      = prompts

            @logger = Logger.new self.class.name
          end

          def to_message
            message = {
              :'message number' => Message::SSH_MSG_USERAUTH_INFO_REQUEST::VALUE,
              :'name'           => @name,
              :'instruction'    => @instruction,
              :'language tag'   => @language_tag,
              :'num-prompts'    => @prompts.size,
            }
            message_prompts = @prompts.map.with_index{ |(prompt, echo), i|
              [
                [:"prompt[#{i+1}]", prompt],
                [:"echo[#{i+1}]",   echo],
              ].to_h
            }.inject(Hash.new){ |a, b| a.merge(b) }
            message.merge(message_prompts)
          end

          def to_payload
            Message::SSH_MSG_USERAUTH_INFO_REQUEST.encode self.to_message
          end
        end
      end
    end
  end
end
