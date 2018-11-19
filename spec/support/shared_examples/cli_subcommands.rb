RSpec.shared_examples 'CLI with sub-command' do |command|
  describe "##{command}" do
    subject(:cli_command) { capture(:stdout) { cli.send command } }

    it { is_expected.to include(*subcommands) }
  end
end
