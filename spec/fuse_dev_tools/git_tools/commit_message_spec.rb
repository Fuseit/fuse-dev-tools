require 'fuse_dev_tools/git_tools/commit_message'

RSpec.describe FuseDevTools::GitTools::CommitMessage do
  subject(:commit_message) { described_class.new message: message }

  let(:message) { [type, task_id, task_description].join(' ') + commit_description }
  let(:type) { described_class::VALID_TYPES.sample }
  let(:task_id) { [task_project, '-', task_number].join }
  let(:task_project) { ('A'..'Z').to_a.sample(4).join }
  let(:task_number) { (0..9).to_a.sample(4).join }
  let(:task_description) { 'A short but brief description' }
  let(:commit_description) do
    "\n\nThis is a much longer, detailed description that may even span\nmultiple lines!\n\nOr paragraphs!"
  end

  describe '#parse' do
    subject(:parse) { commit_message.parse }

    it { expect { parse }.to change { commit_message.type }.from(nil).to(type) }
    it { expect { parse }.to change { commit_message.task_id }.from(nil).to(task_id) }
    it { expect { parse }.to change { commit_message.task_description }.from(nil).to(task_description) }
    it { expect { parse }.to change { commit_message.commit_description }.from(nil).to(commit_description) }

    context 'when :message cannot be parsed' do
      let(:message) { 'This commit message has invalid format' }

      its('errors.messages') { is_expected.to have_key :message }
    end
  end

  describe '#valid?' do
    subject(:parsed_commit_message) { commit_message.parse }

    it { is_expected.to be_valid }

    context 'when message is automated via branch merging' do
      let(:message) { "Merge branch 'master' into dev" }

      it { is_expected.to be_valid }
    end

    context 'when :type is not provided' do
      let(:message) { [task_id, task_description].join(' ') + commit_description }

      before { parsed_commit_message.valid? }

      its('errors.messages') { is_expected.to have_key :type }
    end

    context 'when :type is not included types' do
      let(:type) { 'potato' }

      it { is_expected.not_to be_valid }
    end

    context 'when :task_description is not provided' do
      let(:task_description) { nil }

      before { parsed_commit_message.valid? }

      its('errors.messages') { is_expected.to have_key :task_description }
    end

    describe ':commit_description' do
      before { parsed_commit_message.valid? }

      context 'when it is not provided' do
        let(:commit_description) { '' }

        it { is_expected.to be_valid }
      end

      context 'when it starts with only 1 new line' do
        let(:commit_description) { "\nThis commit description starts with 1 new line." }

        its('errors.messages') { is_expected.to have_key :commit_description }
      end

      context 'when it starts with more than 2 new lines' do
        let(:commit_description) { "\n\n\nThis commit description starts with 1 new line." }

        it { is_expected.to be_valid }
      end
    end

    describe ':task_id' do
      before { commit_message.parse.valid? }

      context 'when it is not provided' do
        let(:message) { [type, task_description].join(' ') + commit_description }

        it { is_expected.to be_valid }
      end

      context 'when project is blank' do
        let(:task_project) { '' }

        it { is_expected.not_to be_valid }
      end

      context 'when project is lowercase' do
        let(:task_project) { ('a'..'z').to_a.sample(4).join }

        its('errors.messages') { is_expected.to have_key :task_id }
      end

      context 'when project is mixed-case' do
        let(:task_project) { 'Fuse' }

        its('errors.messages') { is_expected.to have_key :task_id }
      end

      context 'when project contains numbers' do
        let(:task_project) { (0..9).to_a.sample(4).join }

        its('errors.messages') { is_expected.to have_key :task_id }
      end

      context 'when number includes non-numbers' do
        let(:task_number) { 'FF8' }

        its('errors.messages') { is_expected.to have_key :task_id }
      end
    end
  end
end
