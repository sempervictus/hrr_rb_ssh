# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_CHANNEL_FAILURE do
  let(:id){ 'SSH_MSG_CHANNEL_FAILURE' }
  let(:value){ 100 }

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

  let(:message){
    {
      :'message number'    => value,
      :'recipient channel' => 1,
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataType::Byte.encode(message[:'message number']),
      HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
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
