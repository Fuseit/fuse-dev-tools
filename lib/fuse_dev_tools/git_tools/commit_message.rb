require 'active_model'
require 'virtus'

module FuseDevTools
  module GitTools
    class CommitMessage
      include ::ActiveModel::Model
      include ::Virtus.model

      attribute :message, String
      attribute :type, String
      attribute :task_id, String
      attribute :task_description, String
      attribute :commit_description, String

      VALID_TYPES = %w[feature fix hotfix chore refactor build test].freeze
      TYPE_REGEX = Regexp.union VALID_TYPES
      TASK_ID_REGEX = /[\w]+\-[\w]+/.freeze
      STRICT_TASK_ID_REGEX = /[A-Z]+\-\d+/.freeze
      TASK_DESCRIPTION_REGEX = /[\w]+.*/.freeze
      COMMIT_DESCRIPTION_REGEX = /(\n\n?([\w\s[:punct:]]+))?/.freeze

      # NOTE: Matching positions
      # 1 - type
      # 2 - task_id (optional, defaults to nil)
      # 3 - task_description
      # 4 - commit_description (optional, defaults to nil)
      MESSAGE_REGEX = \
        /^(#{TYPE_REGEX})?(?: ?(#{TASK_ID_REGEX}))?(?: (#{TASK_DESCRIPTION_REGEX})?)#{COMMIT_DESCRIPTION_REGEX}/.freeze

      BUMP_VERSION_REGEX = /^(?:chore )*([Bb]ump [Vv]ersion|[Vv]ersion [Bb]ump)/.freeze
      MERGE_COMMIT_REGEX = /^(?:chore )*Merge (?:branch|pull request)/.freeze

      validates :type, inclusion: { in: VALID_TYPES }, unless: :skip_validations?
      validates :message, :task_description, presence: true, allow_blank: false, unless: :skip_validations?
      validate :task_id_validations, :task_description_validations, :commit_description_validations,
        unless: :skip_validations?

      def parse
        commit_message, @type, @task_id, @task_description, @commit_description = message.match(MESSAGE_REGEX).to_a
        errors.add(:message) unless commit_message
        self
      end

      def warning_message
        "Please ensure your commit message has the following format:\n" +
          valid_message_format +
          "\nMore info: https://fuseuniversal.atlassian.net/wiki/spaces/FD/pages/354942977/Commit+message+formatting"
      end

      def bump_version_commit?
        message.presence && message =~ BUMP_VERSION_REGEX
      end

      def merge_commit?
        message.presence && message =~ MERGE_COMMIT_REGEX
      end

      private

        def valid_message_format
          "\n    <type> <task_id> <task_description>\n\n    <commit_description>\n"
        end

        def task_id_validations
          errors.add(:task_id) if task_id.presence && task_id.match(STRICT_TASK_ID_REGEX).nil?
        end

        def task_description_validations
          if task_description.presence
            errors.add(:task_description) if task_description.match(TASK_DESCRIPTION_REGEX).nil?
          else
            errors.add(:task_description)
          end
        end

        def commit_description_validations
          errors.add(:commit_description) if commit_description.presence && !commit_description.start_with?("\n\n")
        end

        def skip_validations?
          merge_commit?
        end
    end
  end
end
