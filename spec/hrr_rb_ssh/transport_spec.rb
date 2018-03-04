# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport do
  before :all do
    class MockSocket
      def initialize
        @incoming_read, @incoming_write = IO.pipe
        @outgoing_read, @outgoing_write = IO.pipe
      end
      def local_read   x; @incoming_read.read   x; end
      def local_write  x; @outgoing_write.write x; end
      def remote_read  x; @outgoing_read.read   x; end
      def remote_write x; @incoming_write.write x; end
      alias read  local_read
      alias write local_write
    end
  end

  describe '#initialize' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "takes two arguments: io and mode" do
      expect { transport }.not_to raise_error
    end

    it "initializes incoming_sequence_number readable" do
      expect(transport.incoming_sequence_number).to be_an_instance_of HrrRbSsh::Transport::SequenceNumber
      expect(transport.incoming_sequence_number.sequence_number).to eq 0
    end

    it "initializes outgoing_sequence_number readable" do
      expect(transport.outgoing_sequence_number).to be_an_instance_of HrrRbSsh::Transport::SequenceNumber
      expect(transport.outgoing_sequence_number.sequence_number).to eq 0
    end

    it "initializes server_host_key_algorithm readable" do
      expect(transport.server_host_key_algorithm).to be nil
    end

    it "initializes incoming_encryption_algorithm readable" do
      expect(transport.incoming_encryption_algorithm).to be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::None
    end

    it "initializes incoming_mac_algorithm readable" do
      expect(transport.incoming_mac_algorithm).to be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::None
    end

    it "initializes incoming_compression_algorithm readable" do
      expect(transport.incoming_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
    end

    it "initializes outgoing_encryption_algorithm readable" do
      expect(transport.outgoing_encryption_algorithm).to be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::None
    end

    it "initializes outgoing_mac_algorithm readable" do
      expect(transport.outgoing_mac_algorithm).to be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::None
    end

    it "initializes outgoing_compression_algorithm readable" do
      expect(transport.outgoing_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
    end

    it "initializes v_c readable" do
      expect(transport.v_c).to be nil
    end

    it "initializes v_s readable" do
      expect(transport.v_s).to be nil
    end

    it "initializes i_c readable" do
      expect(transport.i_c).to be nil
    end

    it "initializes i_s readable" do
      expect(transport.i_s).to be nil
    end
  end

  context "when mode is server" do
    let(:io){ MockSocket.new }
    let(:mode){ HrrRbSsh::Transport::Mode::SERVER }

    describe "#exchange_version" do
      let(:transport){ described_class.new io, mode }
      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      it "sends SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION} || CR || LF" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(io.remote_read 24).to eq (local_version_string + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
      end

      it "receives remote version string and updates v_c" do
        expect(transport.v_c).to be nil
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq remote_version_string
      end

      it "updates v_s" do
        expect(transport.v_s).to be nil
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq local_version_string
      end

      it "skips data before remote version string" do
        expect(transport.v_c).to be nil
        io.remote_write ("initial data" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq remote_version_string
      end
    end

    describe "#exchange_key" do
      let(:transport){ described_class.new io, mode }

      let(:mock_sender  ){ double("mock sender") }
      let(:mock_receiver){ double("mock receiver") }

      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      let(:remote_kexinit_message){
        {
          "SSH_MSG_KEXINIT"                         => 20,
          "cookie (random byte)"                    => 37,
          "kex_algorithms"                          => ["diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"],
          "server_host_key_algorithms"              => ["ssh-rsa", "ssh-dss"],
          "encryption_algorithms_client_to_server"  => ["aes128-cbc", "aes256-cbc"],
          "encryption_algorithms_server_to_client"  => ["aes128-cbc", "aes256-cbc"],
          "mac_algorithms_client_to_server"         => ["hmac-sha1", "hmac-md5"],
          "mac_algorithms_server_to_client"         => ["hmac-sha1", "hmac-md5"],
          "compression_algorithms_client_to_server" => ["none", "zlib@openssh.com", "zlib"],
          "compression_algorithms_server_to_client" => ["none", "zlib@openssh.com", "zlib"],
          "languages_client_to_server"              => [],
          "languages_server_to_client"              => [],
          "first_kex_packet_follows"                => false,
          "0 (reserved for future extension)"       => 0
        }
      }
      let(:remote_kexinit_payload){ HrrRbSsh::Message::SSH_MSG_KEXINIT.encode remote_kexinit_message }
      let(:remote_kexdh_init_message){
        {
          "SSH_MSG_KEXDH_INIT" => 30,
          "e"                  => remote_dh_pub_key,
        }
      }
      let(:remote_kexdh_init_payload){ HrrRbSsh::Message::SSH_MSG_KEXDH_INIT.encode remote_kexdh_init_message }
      let(:dh_group14_p){
        "FFFFFFFF" "FFFFFFFF" "C90FDAA2" "2168C234" \
        "C4C6628B" "80DC1CD1" "29024E08" "8A67CC74" \
        "020BBEA6" "3B139B22" "514A0879" "8E3404DD" \
        "EF9519B3" "CD3A431B" "302B0A6D" "F25F1437" \
        "4FE1356D" "6D51C245" "E485B576" "625E7EC6" \
        "F44C42E9" "A637ED6B" "0BFF5CB6" "F406B7ED" \
        "EE386BFB" "5A899FA5" "AE9F2411" "7C4B1FE6" \
        "49286651" "ECE45B3D" "C2007CB8" "A163BF05" \
        "98DA4836" "1C55D39A" "69163FA8" "FD24CF5F" \
        "83655D23" "DCA3AD96" "1C62F356" "208552BB" \
        "9ED52907" "7096966D" "670C354E" "4ABC9804" \
        "F1746C08" "CA18217C" "32905E46" "2E36CE3B" \
        "E39E772C" "180E8603" "9B2783A2" "EC07A28F" \
        "B5C55DF0" "6F4C52C9" "DE2BCBF6" "95581718" \
        "3995497C" "EA956AE5" "15D22618" "98FA0510" \
        "15728E5A" "8AACAA68" "FFFFFFFF" "FFFFFFFF"
      }
      let(:dh_group14_g){
        2
      }
      let(:remote_dh){
        dh = OpenSSL::PKey::DH.new
        dh.set_pqg OpenSSL::BN.new(dh_group14_p, 16), nil, OpenSSL::BN.new(dh_group14_g)
        dh.generate_key!
        dh
      }
      let(:remote_dh_pub_key){ 
        OpenSSL::BN.new(remote_dh.pub_key, 2).to_i
      }
      let(:remote_newkeys_message){
        {
          "SSH_MSG_NEWKEYS" => 21,
        }
      }
      let(:remote_newkeys_payload){ HrrRbSsh::Message::SSH_MSG_NEWKEYS.encode remote_newkeys_message }

      before :example do
        transport.instance_variable_set('@sender',   mock_sender  )
        transport.instance_variable_set('@receiver', mock_receiver)

        transport.instance_variable_set('@v_c', remote_version_string)
        transport.instance_variable_set('@v_s', local_version_string )
      end

      it "updates i_c and i_s" do
        local_kexinit_message = {
          "SSH_MSG_KEXINIT"                         => HrrRbSsh::Message::SSH_MSG_KEXINIT::VALUE,
          'cookie (random byte)'                    => lambda { rand(0x01_00) },
          "kex_algorithms"                          => HrrRbSsh::Transport::KexAlgorithm.name_list,
          "server_host_key_algorithms"              => HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list,
          "encryption_algorithms_client_to_server"  => HrrRbSsh::Transport::EncryptionAlgorithm.name_list,
          "encryption_algorithms_server_to_client"  => HrrRbSsh::Transport::EncryptionAlgorithm.name_list,
          "mac_algorithms_client_to_server"         => HrrRbSsh::Transport::MacAlgorithm.name_list,
          "mac_algorithms_server_to_client"         => HrrRbSsh::Transport::MacAlgorithm.name_list,
          "compression_algorithms_client_to_server" => HrrRbSsh::Transport::CompressionAlgorithm.name_list,
          "compression_algorithms_server_to_client" => HrrRbSsh::Transport::CompressionAlgorithm.name_list,
          "languages_client_to_server"              => [],
          "languages_server_to_client"              => [],
          "first_kex_packet_follows"                => false,
          "0 (reserved for future extension)"       => 0
        }
        local_kexinit_payload = HrrRbSsh::Message::SSH_MSG_KEXINIT.encode(local_kexinit_message)

        expect(transport.i_c).to be nil
        expect(transport.i_s).to be nil

        expect(mock_sender).to   receive(:send).with(transport, match(local_kexinit_payload[17..(local_kexinit_payload.length-1)])).once
        expect(mock_sender).to   receive(:send).with(transport, anything).twice
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload, remote_kexdh_init_payload, remote_newkeys_payload).exactly(3).times

        transport.exchange_key

        expect(transport.i_c).to eq remote_kexinit_payload

        i_s = StringIO.new transport.i_s, 'r'
        expect(i_s.read(1).unpack("C")[0]).to eq 20
        16.times do
          expect(i_s.read(1).unpack("C")[0]).to be_between(0x00, 0xff).inclusive
        end
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::KexAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::EncryptionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::EncryptionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::MacAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::MacAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::CompressionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::CompressionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq []
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq []
        expect(HrrRbSsh::Transport::DataType::Boolean.decode i_s).to eq false
        expect(HrrRbSsh::Transport::DataType::Uint32.decode i_s).to eq 0
        expect(i_s.read).to eq ""
      end

      it "updates kex_algorithm" do
        expect(mock_sender).to   receive(:send).with(transport, anything).exactly(3).times
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload, remote_kexdh_init_payload, remote_newkeys_payload).exactly(3).times

        transport.exchange_key

        expect(transport.server_host_key_algorithm).to be_an_instance_of HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa
        expect(transport.instance_variable_get('@kex_algorithm')).to be_an_instance_of HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup14Sha1
      end

      it "gets shared secret" do
        expect(mock_sender).to   receive(:send).with(transport, anything).exactly(3).times
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload, remote_kexdh_init_payload, remote_newkeys_payload).exactly(3).times

        transport.exchange_key

        local_kex_algorithm  = transport.instance_variable_get('@kex_algorithm')
        local_e              = local_kex_algorithm.pub_key
        local_shared_secret  = local_kex_algorithm.shared_secret
        remote_shared_secret = OpenSSL::BN.new(remote_dh.compute_key(local_e), 2).to_i
        expect(local_shared_secret).to eq remote_shared_secret
      end

      it "updates encryption, mac, and compression algorithms" do
        expect(mock_sender).to   receive(:send).with(transport, anything).exactly(3).times
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload, remote_kexdh_init_payload, remote_newkeys_payload).exactly(3).times

        transport.exchange_key

        expect(transport.incoming_encryption_algorithm).to  be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::Aes128Cbc
        expect(transport.outgoing_encryption_algorithm).to  be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::Aes128Cbc
        expect(transport.incoming_mac_algorithm).to         be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::HmacSha1
        expect(transport.outgoing_mac_algorithm).to         be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::HmacSha1
        expect(transport.incoming_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
        expect(transport.outgoing_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
      end
    end
  end

  context "when mode is client" do
    let(:io){ MockSocket.new }
    let(:mode){ HrrRbSsh::Transport::Mode::CLIENT }

    describe "#exchange_version" do
      let(:transport){ described_class.new io, mode }
      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      it "sends SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION} || CR || LF" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(io.remote_read 24).to eq (local_version_string + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
      end

      it "receives remote version string and updates v_s" do
        expect(transport.v_s).to be nil
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq remote_version_string
      end

      it "updates v_c" do
        expect(transport.v_c).to be nil
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq local_version_string
      end

      it "skips data before remote version string" do
        expect(transport.v_s).to be nil
        io.remote_write ("initial data" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq remote_version_string
      end
    end

    describe "#exchange_key" do
      let(:transport){ described_class.new io, mode }

      let(:mock_sender  ){ double("mock sender") }
      let(:mock_receiver){ double("mock receiver") }

      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      let(:remote_kexinit_message){
        {
          "SSH_MSG_KEXINIT"                         => 20,
          "cookie (random byte)"                    => 37,
          "kex_algorithms"                          => ["diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"],
          "server_host_key_algorithms"              => ["ssh-rsa", "ssh-dss"],
          "encryption_algorithms_client_to_server"  => ["aes128-cbc", "aes256-cbc"],
          "encryption_algorithms_server_to_client"  => ["aes128-cbc", "aes256-cbc"],
          "mac_algorithms_client_to_server"         => ["hmac-sha1", "hmac-md5"],
          "mac_algorithms_server_to_client"         => ["hmac-sha1", "hmac-md5"],
          "compression_algorithms_client_to_server" => ["none", "zlib@openssh.com", "zlib"],
          "compression_algorithms_server_to_client" => ["none", "zlib@openssh.com", "zlib"],
          "languages_client_to_server"              => [],
          "languages_server_to_client"              => [],
          "first_kex_packet_follows"                => false,
          "0 (reserved for future extension)"       => 0
        }
      }
      let(:remote_kexinit_payload){ HrrRbSsh::Message::SSH_MSG_KEXINIT.encode remote_kexinit_message }

      before :example do
        transport.instance_variable_set('@sender',   mock_sender  )
        transport.instance_variable_set('@receiver', mock_receiver)

        transport.instance_variable_set('@v_s', remote_version_string)
        transport.instance_variable_set('@v_c', local_version_string )
      end

      it "updates i_c and i_s" do
        local_kexinit_message = {
          "SSH_MSG_KEXINIT"                         => HrrRbSsh::Message::SSH_MSG_KEXINIT::VALUE,
          'cookie (random byte)'                    => lambda { rand(0x01_00) },
          "kex_algorithms"                          => HrrRbSsh::Transport::KexAlgorithm.name_list,
          "server_host_key_algorithms"              => HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list,
          "encryption_algorithms_client_to_server"  => HrrRbSsh::Transport::EncryptionAlgorithm.name_list,
          "encryption_algorithms_server_to_client"  => HrrRbSsh::Transport::EncryptionAlgorithm.name_list,
          "mac_algorithms_client_to_server"         => HrrRbSsh::Transport::MacAlgorithm.name_list,
          "mac_algorithms_server_to_client"         => HrrRbSsh::Transport::MacAlgorithm.name_list,
          "compression_algorithms_client_to_server" => HrrRbSsh::Transport::CompressionAlgorithm.name_list,
          "compression_algorithms_server_to_client" => HrrRbSsh::Transport::CompressionAlgorithm.name_list,
          "languages_client_to_server"              => [],
          "languages_server_to_client"              => [],
          "first_kex_packet_follows"                => false,
          "0 (reserved for future extension)"       => 0
        }
        local_kexinit_payload = HrrRbSsh::Message::SSH_MSG_KEXINIT.encode(local_kexinit_message)

        expect(transport.i_c).to be nil
        expect(transport.i_s).to be nil

        expect(mock_sender).to   receive(:send).with(transport, match(local_kexinit_payload[17..(local_kexinit_payload.length-1)])).once
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload).once

        transport.exchange_key

        expect(transport.i_s).to eq remote_kexinit_payload

        i_c = StringIO.new transport.i_c, 'r'
        expect(i_c.read(1).unpack("C")[0]).to eq 20
        16.times do
          expect(i_c.read(1).unpack("C")[0]).to be_between(0x00, 0xff).inclusive
        end
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::KexAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::EncryptionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::EncryptionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::MacAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::MacAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::CompressionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::CompressionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq []
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq []
        expect(HrrRbSsh::Transport::DataType::Boolean.decode i_c).to eq false
        expect(HrrRbSsh::Transport::DataType::Uint32.decode i_c).to eq 0
        expect(i_c.read).to eq ""
      end

      it "updates kex_algorithm" do
        expect(mock_sender).to   receive(:send).with(transport, anything).once
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload).once

        transport.exchange_key

        expect(transport.server_host_key_algorithm).to be_an_instance_of HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa
        expect(transport.instance_variable_get('@kex_algorithm')).to be_an_instance_of HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup1Sha1
      end
    end
  end
end
