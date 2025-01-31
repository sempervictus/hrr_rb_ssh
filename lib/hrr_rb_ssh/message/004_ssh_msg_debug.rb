# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_DEBUG
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 4

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Boolean,   :'always_display'],
        [DataType::String,    :'message'],
        [DataType::String,    :'language tag'],
      ]
    end
  end
end
