# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType::PtyReq::Context do
  let(:proc_chain){ "proc_chain" }
  let(:username){ "username" }
  let(:io){ 'dummy' }
  let(:variables){ Hash.new }
  let(:message){
    {
      :'message number'                  => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
      :'recipient channel'               => 1,
      :'request type'                    => 'pty-req',
      :'want reply'                      => true,
      :'TERM environment variable value' => 'foo',
      :'terminal width, characters'      => 80,
      :'terminal height, rows'           => 24,
      :'terminal width, pixels'          => 400,
      :'terminal height, pixels'         => 120,
      :'encoded terminal modes'          => 'bar',
    }
  }
  let(:context){ described_class.new proc_chain, username, io, variables, message }

  describe ".new" do
    it "takes 4 arguments" do
      expect { context }.not_to raise_error
    end
  end

  describe "#chain_proc" do

    context "with block" do
      let(:chain_proc){
        Proc.new {}
      }

      it "receives a block and returns a proc based on the block" do
        context.chain_proc &chain_proc
        expect(context.chain_proc).to be chain_proc
      end
    end

    context "with no block" do
      it "returns nil" do
        context.chain_proc
        expect(context.chain_proc).to be nil
      end
    end
  end

  describe "#logger" do
    it "returns an instance of HrrRbSsh::Logger" do
      expect(context.logger).to be_an_instance_of HrrRbSsh::Logger
    end
  end

  describe "#io" do
    it "returns 'io' object" do
      expect(context.io).to be io
    end
  end

  describe "#variables" do
    it "returns 'variables' object" do
      expect(context.variables).to be variables
    end
  end

  describe "#vars" do
    it "returns 'variables' object" do
      expect(context.vars).to be variables
    end
  end

  describe "#term_environment_variable_value" do
    it "returns message[:'TERM environment variable value']" do
      expect(context.term_environment_variable_value).to be message[:'TERM environment variable value']
    end
  end

  describe "#terminal_width_characters" do
    it "returns message[:'terminal width, characters']" do
      expect(context.terminal_width_characters).to be message[:'terminal width, characters']
    end
  end

  describe "#terminal_height_rows" do
    it "returns message[:'terminal height, rows']" do
      expect(context.terminal_height_rows).to be message[:'terminal height, rows']
    end
  end

  describe "#terminal_width_pixels" do
    it "returns message[:'terminal width, pixels']" do
      expect(context.terminal_width_pixels).to be message[:'terminal width, pixels']
    end
  end

  describe "#terminal_height_pixels" do
    it "returns message[:'terminal height, pixels']" do
      expect(context.terminal_height_pixels).to be message[:'terminal height, pixels']
    end
  end

  describe "#encoded_terminal_modes" do
    it "returns message[:'encoded terminal modes']" do
      expect(context.encoded_terminal_modes).to be message[:'encoded terminal modes']
    end
  end
end
