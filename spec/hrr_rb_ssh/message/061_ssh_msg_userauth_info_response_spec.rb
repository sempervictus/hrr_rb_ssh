# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_USERAUTH_INFO_RESPONSE do
  let(:id){ 'SSH_MSG_USERAUTH_INFO_RESPONSE' }
  let(:value){ 61 }

  describe "::ID" do
    it "is defined" do
      expect(described_class::ID).to eq id
    end
  end

  describe "::VALUE" do
    it "is defined" do
      expect(described_class::VALUE).to eq value
    end
  end

  context "when 'num-responses' is 0" do
    let(:message){
      {
        :'message number' => value,
        :'num-responses'  => 0,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'num-responses']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'num-responses' is 1" do
    let(:message){
      {
        :'message number' => value,
        :'num-responses'  => 1,
        :'response[1]'    => 'response[1]',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'num-responses']),
        HrrRbSsh::DataType::String.encode(message[:'response[1]']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'num-responses' is 2" do
    let(:message){
      {
        :'message number' => value,
        :'num-responses'  => 2,
        :'response[1]'    => 'response[1]',
        :'response[2]'    => 'response[2]',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'num-responses']),
        HrrRbSsh::DataType::String.encode(message[:'response[1]']),
        HrrRbSsh::DataType::String.encode(message[:'response[2]']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end

  context "when 'num-responses' is 3" do
    let(:message){
      {
        :'message number' => value,
        :'num-responses'  => 3,
        :'response[1]'    => 'response[1]',
        :'response[2]'    => 'response[2]',
        :'response[3]'    => 'response[3]',
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'num-responses']),
        HrrRbSsh::DataType::String.encode(message[:'response[1]']),
        HrrRbSsh::DataType::String.encode(message[:'response[2]']),
        HrrRbSsh::DataType::String.encode(message[:'response[3]']),
      ].join
    }

    describe ".encode" do
      it "returns payload encoded" do
        expect(described_class.encode(message)).to eq payload
      end
    end

    describe ".decode" do
      it "returns message decoded" do
        expect(described_class.decode(payload)).to eq message
      end
    end
  end
end
