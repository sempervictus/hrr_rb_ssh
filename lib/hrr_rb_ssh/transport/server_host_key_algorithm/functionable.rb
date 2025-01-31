# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      module Functionable
        def initialize secret_key=nil
          @logger = Logger.new(self.class.name)
          @publickey = Algorithm::Publickey[self.class::NAME].new (secret_key || self.class::SECRET_KEY)
        end

        def server_public_host_key
          @publickey.to_public_key_blob
        end

        def sign signature_blob
          @publickey.sign signature_blob
        end

        def verify signature, signature_blob
          @publickey.verify signature, signature_blob
        end
      end
    end
  end
end
