RSpec.shared_examples 'CLI with sub-command' do |command|
  describe "##{command}" do
    subject { capture(:stdout) { cli.send command } }

    it { is_expected.to include 'Commands:' }
  end
end
