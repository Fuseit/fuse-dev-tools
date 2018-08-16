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

      validates :type, inclusion: { in: VALID_TYPES }, unless: :skip_validations?
      validates :message, :task_description, presence: true, allow_blank: false, unless: :skip_validations?
      validate :task_id_validations, :task_description_validations, :commit_description_validations,
        unless: :skip_validations?

      def parse
        matched_message = message.match(message_regex)
        raise_error! if matched_message.nil?

        @type = matched_message[1]
        @task_id = matched_message[2]
        @task_description = matched_message[3]
        @commit_description = matched_message[4]

        self
      rescue ArgumentError
        errors.add(:message)
        self
      end

      def warning_message
        "Please ensure your commit message has the following format:\n" +
          valid_message_format +
          "\nMore info: https://fuseuniversal.atlassian.net/wiki/spaces/FD/pages/354942977/Commit+message+formatting"
      end

      private

        def message_regex
          # TODO: Consider joining regex method definitions in this method for greater clarity
          # Matching positions
          # 1 - type
          # 2 - task_id (optional, defaults to nil)
          # 3 - task_description
          # 4 - commit_description (optional, defaults to nil)
          /^(#{VALID_TYPES.join('|')}){1}?(?:\s?([\d\w]+-[\d\w]+))?(?:\s([\w]+.*))(\n\n?([\w\d\s[:punct:]]+))?/
        end

        def type_regex
          /^(#{VALID_TYPES.join('|')}){1}/
        end

        def task_id_regex
          /(?:\s?([\d\w]+-[\d\w]+))/
        end

        def strict_task_id_regex
          /([A-Z]+-[\d]+)/
        end

        def task_description_regex
          /(?:\s([\w]+.*))/
        end

        def commit_description_regex
          /(\n\n?([\w\d\s[:punct:]]+))?/
        end

        def raise_error!
          raise ArgumentError
        end

        def valid_message_format
          "\n    <type> <task_id> <task_description>\n\n    <commit_description>\n"
        end

        def task_id_validations
          errors.add(:task_id) if task_id.presence && task_id.match(strict_task_id_regex).nil?
        end

        def task_description_validations
          errors.add(:task_description) if task_description.presence && task_description.match(task_id_regex)
        end

        def commit_description_validations
          errors.add(:commit_description) if commit_description.presence && !commit_description.start_with?("\n\n")
        end

        def skip_validations?
          message.presence && message.start_with?('Merge branch')
        end
    end
  end
end
