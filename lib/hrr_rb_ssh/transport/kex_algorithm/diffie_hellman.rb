# coding: utf-8
# vim: et ts=2 sw=2

require 'openssl'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/transport/kex_algorithm/iv_computable'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      module DiffieHellman
        include IvComputable

        def initialize
          @logger = Logger.new(self.class.name)
          @dh = OpenSSL::PKey::DH.new
          if @dh.respond_to?(:set_pqg)
            @dh.set_pqg OpenSSL::BN.new(self.class::P, 16), nil, OpenSSL::BN.new(self.class::G)
          else
            @dh.p = OpenSSL::BN.new(self.class::P, 16)
            @dh.g = OpenSSL::BN.new(self.class::G)
          end
          @dh.generate_key!
        end

        def start transport, mode
          case mode
          when Mode::SERVER
            receive_kexdh_init transport.receive
            send_kexdh_reply transport
          else
            raise "unsupported mode"
          end
        end

        def set_e e
          @e = e
        end

        def shared_secret
          k = OpenSSL::BN.new(@dh.compute_key(OpenSSL::BN.new(@e)), 2).to_i
        end

        def pub_key
          f = @dh.pub_key.to_i
        end

        def hash transport
          e = @e
          k = shared_secret
          f = pub_key

          h0_payload = {
            :'V_C' => transport.v_c,
            :'V_S' => transport.v_s,
            :'I_C' => transport.i_c,
            :'I_S' => transport.i_s,
            :'K_S' => transport.server_host_key_algorithm.server_public_host_key,
            :'e'   => e,
            :'f'   => f,
            :'k'   => k,
          }
          h0 = H0.encode h0_payload

          h = OpenSSL::Digest.digest self.class::DIGEST, h0

          h
        end

        def sign transport
          h = hash transport
          s = transport.server_host_key_algorithm.sign h

          s
        end

        def receive_kexdh_init payload
          message = Message::SSH_MSG_KEXDH_INIT.decode payload
          set_e message[:'e']
        end

        def send_kexdh_reply transport
          message = {
            :'message number'                                => Message::SSH_MSG_KEXDH_REPLY::VALUE,
            :'server public host key and certificates (K_S)' => transport.server_host_key_algorithm.server_public_host_key,
            :'f'                                             => pub_key,
            :'signature of H'                                => sign(transport),
          }
          payload = Message::SSH_MSG_KEXDH_REPLY.encode message
          transport.send payload
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman/h0'
