# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_IGNORE
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 2

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'SSH_MSG_IGNORE'],
        ['string',    'data'],
      ]
    end
  end
end