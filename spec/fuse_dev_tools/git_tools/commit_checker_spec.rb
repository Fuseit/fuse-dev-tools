require 'fuse_dev_tools/git_tools/commit_checker'

RSpec.describe FuseDevTools::GitTools::CommitChecker do
  let(:checker) { described_class.new }

  describe '#pull_request?' do
    subject { checker.pull_request?(branch_name) }

    context 'when branch name is a special branch' do
      %w[
        master dev feature-deploy-mobile feature-deploy-fantom feature-deploy-
        release/v3.46 release-3.46 hotfix-deploy
      ].each do |branch|
        let(:branch_name) { branch }

        it { is_expected.to be_falsey }
      end
    end

    context 'when branch name is not a special branch' do
      %w[hotfix/my-hotfix my-hotfix feature/my-feature my-feature my-chore fix/my-fix my-fix].each do |branch|
        let(:branch_name) { branch }

        it { is_expected.to be_truthy }
      end
    end
  end
end
