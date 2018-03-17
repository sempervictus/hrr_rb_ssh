# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/authentication/authenticator'
require 'hrr_rb_ssh/authentication/method'

module HrrRbSsh
  class Authentication
    SERVICE_NAME = 'ssh-userauth'

    def initialize transport, options={}
      @transport = transport
      @options = options

      @logger = HrrRbSsh::Logger.new self.class.name

      @transport.register_acceptable_service SERVICE_NAME
    end

    def start
      @transport.start
    end
  end
end