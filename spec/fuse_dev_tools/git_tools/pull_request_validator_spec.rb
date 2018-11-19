require 'fuse_dev_tools/git_tools/pull_request_validator'

RSpec.describe FuseDevTools::GitTools::PullRequestValidator do
  subject(:validator) { described_class.new }

  let(:stubbed_commit_checker) do
    instance_double '::FuseDevTools::GitTools::CommitChecker',
      file_changed?: changelog_changed,
      pull_request?: is_pull_request
  end
  let(:changelog_changed) { true }
  let(:is_pull_request) { false }
  let(:latest_commit_message) { 'chore Fix commit' }

  describe '#valid? and changelog' do
    subject { validator.valid? }

    before do
      allow(validator).to receive(:commit_checker).and_return stubbed_commit_checker
      allow(validator).to receive(:latest_commit_message).and_return latest_commit_message
    end

    context 'when commit message is bump version' do
      [
        'chore Bump version', 'chore Version bump', 'Bump version', 'Version bump', 'chore Bump version staging'
      ].each do |commit_message|
        let(:latest_commit_message) { commit_message }

        it { is_expected.to be_truthy }
      end
    end

    context 'when commit message is merge commit' do
      [
        'Merge', 'Merge branch', 'Merge pull request', 'chore Merge', 'chore Merge branch', 'chore Merge pull request'
      ].each do |commit_message|
        let(:latest_commit_message) { commit_message }

        it { is_expected.to be_truthy }
      end
    end

    context 'when user is on a PR branch' do
      let(:is_pull_request) { true }

      it { is_expected.to be_falsy }

      context 'when changelog is not altered' do
        let(:changelog_changed) { false }

        it { is_expected.to be_truthy }
      end
    end
  end
end
