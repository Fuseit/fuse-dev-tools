require 'fuse_dev_tools/tasks/git_commands/base'

RSpec.describe FuseDevTools::Tasks::GitCommands::Base, silent: true do
  subject(:cli) { described_class.new }

  describe '#validate_pull_request' do
    subject(:validate_pull_request) { -> { cli.validate_pull_request } }

    let(:stubbed_validator) do
      instance_double('FuseDevTools::GitCommands::PullRequestValidator', valid?: is_valid)
    end
    let(:is_valid) { false }

    before do
      allow(cli).to receive(:validator).and_return stubbed_validator
      allow(cli).to receive(:say_errors)
    end

    it { is_expected.to exit_with_code(1) }

    context 'when validator is valid' do
      let(:is_valid) { true }

      it { is_expected.to exit_with_code(0) }
    end
  end
end
