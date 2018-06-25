RSpec.describe GitHub, vcr: true do
  let(:github_token) { '123token123' }
  let(:organisation) { 'Fuseit' }
  let(:repo) { 'FuseTube' }
  let(:branch) { 'master' }
  let(:last_commit_sha) { 'da0638070343ac5e3cbf9027dd5a60551334df98' }
  let(:head) { 'HEAD' }
  let(:head_minus_one) { 'HEAD~1' }

  before do
    ENV['GITHUB_OAUTH_TOKEN'] = github_token
  end

  describe '.last_commit' do
    subject { described_class.last_commit(organisation, repo, branch) }

    it { is_expected.to eq last_commit_sha }
  end

  describe '.this_last_commit?' do
    subject { described_class.this_last_commit?(organisation, repo, branch, last_commit_sha) }

    it { is_expected.to be_truthy }
  end

  describe '.previous_version?' do
    subject(:previous_version) { described_class.previous_version? organisation, repo }

    it { expect(previous_version).to be_a Semantic::Version }
    it { expect(previous_version.major).to eq 3 }
    it { expect(previous_version.minor).to eq 43 }
    it { expect(previous_version.patch).to eq 4 }
    it { expect(previous_version.to_s).to eq '3.43.4' }
  end

  describe '.next_version?' do
    subject(:next_version) { described_class.next_version? organisation, repo, bump }

    let(:previous_version) { Semantic::Version.new '0.1.0' }

    before do
      allow(described_class).to receive(:previous_version?).and_return previous_version
    end

    context 'when bumping patch' do
      let(:bump) { :patch }

      it { expect(next_version).to eq 'v0.1.1' }
    end

    context 'when bumping minor' do
      let(:bump) { :minor }

      it { expect(next_version).to eq 'v0.2.0' }
    end

    context 'when bumping major' do
      let(:bump) { :major }

      it { expect(next_version).to eq 'v1.0.0' }
    end
  end

  describe '.compare' do
    subject(:compare) { described_class.compare organisation, repo, head_minus_one, head }

    let(:number_of_commits) { 1 }

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
    let(:sha) { 'da06380' }
    let(:message_jira) { 'CS-81' }

    it { expect(comparison.size).to eq number_of_commits }
    it { expect(comparison.first['sha']).to eq sha }
    it { expect(comparison.first['message']).to include message_jira }
  end
end
