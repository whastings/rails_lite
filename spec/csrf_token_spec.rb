require 'rails_lite'

describe CSRFToken do
  subject { CSRFToken.new }

  describe "#generate_token" do
    it "returns a token" do
      expect(subject.generate_token('abc').length).to eq(22)
    end
  end

  describe "#valid_token?" do
    let(:session_id) { 'abcdefg' }
    let(:correct_token) { subject.generate_token(session_id) }
    it "validates a correct token" do
      expect(subject.valid_token?(session_id, correct_token)).to be_true
    end

    it "rejects an incorrect token" do
      correct_token
      expect(subject.valid_token?(session_id, 'hijklmnop')).to be_false
    end
  end
end
