require 'rails_lite'

describe RailsLite do
  subject { RailsLite.new }
  describe "#router" do
    it "returns a Router object" do
      expect(subject.router).to be_instance_of(Router)
    end
  end

  describe "#run" do
    let(:router) { double('router') }
    let(:request) { double('request') }
    let(:response) { double('response') }
    let(:resources) { double('resources') }
    it "calls its Router's run method" do
      subject.stub(:router) { router }
      expect(router).to receive(:run)
      subject.run(request, response)
    end
  end
end
