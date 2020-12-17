RSpec.describe GitHub, vcr: true do
  let(:github_token) { '123token123' }
  let(:organisation) { 'Fuseit' }
  let(:repo) { 'FuseTube' }
  let(:branch) { 'master' }
  let(:head) { 'HEAD' }
  let(:head_minus_one) { 'HEAD~1' }

  before do
    ENV['GITHUB_ACCESS_TOKEN'] = github_token
  end

  describe '.previous_release_version' do
    subject(:previous_release_version) { described_class.previous_release_version organisation, repo }

    it { expect(previous_release_version).to be_a Semantic::Version }
    it { expect(previous_release_version.major).to eq 3 }
    it { expect(previous_release_version.minor).to eq 57 }
    it { expect(previous_release_version.patch).to eq 1 }
    it { expect(previous_release_version.to_s).to eq '3.57.1-pre.1' }
  end

  describe '.next_release_version' do
    subject(:next_release_version) { described_class.next_release_version organisation, repo, bump }

    let(:previous_release_version) { Semantic::Version.new '0.1.0-pre.1' }
    let(:previous_without_pre_release_version) { Semantic::Version.new '0.1.0' }

    before do
      allow(described_class).to receive(:previous_release_version).and_return previous_release_version
    end

    context 'when bumping pre' do
      let(:bump) { :pre }

      it { expect(next_release_version).to eq 'v0.1.0-pre.2' }

      context 'when it a pre first time' do
        before do
          allow(described_class).to receive(:previous_release_version).and_return previous_without_pre_release_version
        end

        it { expect(next_release_version).to eq 'v0.1.0-pre.1' }
      end
    end

    context 'when bumping patch' do
      let(:bump) { :patch }

      it { expect(next_release_version).to eq 'v0.1.1' }
    end

    context 'when bumping minor' do
      let(:bump) { :minor }

      it { expect(next_release_version).to eq 'v0.2.0' }
    end

    context 'when bumping major' do
      let(:bump) { :major }

      it { expect(next_release_version).to eq 'v1.0.0' }
    end
  end

  describe '.compare' do
    subject(:compare) { described_class.compare organisation, repo, head_minus_one, head }

    let(:number_of_commits) { 2 }

    it { expect(compare.commits.size).to eq number_of_commits }
  end

  describe '.comparison_message_commits_count' do
    subject { described_class.comparison_message_commits_count organisation, repo, head_minus_one, head }

    let(:number_of_commits) { 1 }

    it { is_expected.to eq number_of_commits }
  end

  describe '.comparison_message_commits' do
    subject(:comparison) { described_class.comparison_message_commits organisation, repo, head_minus_one, head }

    let(:number_of_commits) { 1 }
    let(:sha) { '2a93cd6' }
    let(:message) { 'chore Bump version to v3.56.8' }

    it { expect(comparison.size).to eq number_of_commits }
    it { expect(comparison.first['sha']).to eq sha }
    it { expect(comparison.first['message']).to include message }
  end
end
