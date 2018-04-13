require 'fuse_dev_tools/cli'
require 'tmpdir'

RSpec.describe FuseDevTools::CLI do
  let(:cli) { described_class.new }

  it_behaves_like 'CLI with sub-command', :application_config
  it_behaves_like 'CLI with sub-command', :database_config
end
