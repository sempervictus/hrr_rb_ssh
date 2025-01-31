# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_KEXDH_REPLY
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 31

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::String,    :'server public host key and certificates (K_S)'],
        [DataType::Mpint,     :'f'],
        [DataType::String,    :'signature of H'],
      ]
    end
  end
end
