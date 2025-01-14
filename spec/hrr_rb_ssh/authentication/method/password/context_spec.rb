# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Password::Context do
  describe ".new" do
    it "takes two arguments: username and password" do
      expect { described_class.new "username", "password" }.not_to raise_error
    end
  end

  describe "#username" do
    let(:context_username){ "username" }
    let(:context_password){ "password" }
    let(:context){ described_class.new context_username, context_password }

    it "returns \"username\"" do
      expect( context.username ).to eq context_username
    end
  end

  describe "#password" do
    let(:context_username){ "username" }
    let(:context_password){ "password" }
    let(:context){ described_class.new context_username, context_password }

    it "returns \"password\"" do
      expect( context.password ).to eq context_password
    end
  end

  describe "#verify" do
    let(:context_username){ "username" }
    let(:context_password){ "password" }
    let(:context){ described_class.new context_username, context_password }
    
    context "with \"username\" and \"password\"" do
      let(:username){ "username" }
      let(:password){ "password" }

      it "returns true" do
        expect( context.verify username, password ).to be true
      end
    end
    
    context "with \"username\" and \"mismatch\"" do
      let(:username){ "username" }
      let(:password){ "mismatch" }

      it "returns false" do
        expect( context.verify username, password ).to be false
      end
    end
    
    context "with \"mismatch\" and \"password\"" do
      let(:username){ "mismatch" }
      let(:password){ "password" }

      it "returns false" do
        expect( context.verify username, password ).to be false
      end
    end
    
    context "with \"mismatch\" and \"mismatch\"" do
      let(:username){ "mismatch" }
      let(:password){ "mismatch" }

      it "returns false" do
        expect( context.verify username, password ).to be false
      end
    end
  end
end
