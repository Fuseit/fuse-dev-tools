require 'fuse_dev_tools/cli'
require 'tmpdir'

RSpec.describe FuseDevTools::CLI do
  let(:cli) { described_class.new }

  it_behaves_like 'CLI with sub-command', :application_config do
    let(:subcommands) { %w[download] }
  end
  it_behaves_like 'CLI with sub-command', :database_config do
    let(:subcommands) { %w[copy] }
  end
  it_behaves_like 'CLI with sub-command', :git do
    let(:subcommands) { %w[validate_commit_message validate_pull_request] }
  end
end
