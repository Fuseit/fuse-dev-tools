RSpec.describe ChangelogBuilder do
  let(:commits) do
    [
      { 'message' => 'fix TEST-1 First thingy', 'sha' => '123asewq' },
      { 'message' => 'chore TEST-2 Second chore thingy', 'sha' => 'asdqwe123' },
      { 'message' => 'feature TEST-3 Third feat thingy', 'sha' => 'dsaewq321' },
      { 'message' => 'TEST-11 Noting to see', 'sha' => 'qweasd32' }
    ]
  end

  let(:builder) { described_class.new(commits) }

  describe '#format_commit_message' do
    subject { builder.send(:format_commit_message, message, sha) }

    let(:message) { 'fix TEST-1 First thingy' }
    let(:sha) { '123asewq' }

    it { is_expected.to eq '* TEST-1 First thingy #123asewq' }
  end

  describe '#categorize_commits' do
    subject(:categorized) { builder.send(:categorized) }

    before { builder.send(:categorize_commits) }

    context 'when features' do
      subject(:features) { categorized[:features] }

      it { expect(features.size).to eq 1 }
      it { expect(features.first).to include 'dsaewq321' }
    end

    context 'when fixes' do
      subject(:fixes) { categorized[:fixes] }

      it { expect(fixes.size).to eq 1 }
      it { expect(fixes.first).to include '123asewq' }
    end

    context 'when technical improvements' do
      subject(:technical_improvements) { categorized[:technical_improvements] }

      it { expect(technical_improvements.size).to eq 1 }
      it { expect(technical_improvements.first).to include 'asdqwe123' }
    end

    context 'when others' do
      subject(:not_categorised) { categorized[:not_categorised] }

      it { expect(not_categorised.size).to eq 1 }
      it { expect(not_categorised.first).to include 'qweasd32' }
    end
  end

  describe '#build' do
    subject(:build) { builder.build }

    it 'builds categorised changelod string' do
      allow(builder).to receive(:categorize_commits)
      build
      expect(builder).to have_received(:categorize_commits)
    end
  end
end
