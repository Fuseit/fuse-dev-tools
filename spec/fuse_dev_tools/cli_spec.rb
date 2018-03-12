require 'fuse_dev_tools/cli'
require 'tmpdir'

RSpec.describe FuseDevTools::CLI do
  let(:cli) { described_class.new }

  describe '#application_config' do
    subject { capture(:stdout) { cli.application_config } }

    it { is_expected.to include 'Commands:' }
  end
end
