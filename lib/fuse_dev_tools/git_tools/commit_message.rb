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

      with_options unless: :skip_validations? do
        validates :type, inclusion: { in: VALID_TYPES }
        validates :message, :task_description, presence: true, allow_blank: false
        validate :validate_task_id_format, if: :task_id
        validate :validate_task_description_format, if: :task_description
        validate :validate_commit_description_format, if: :commit_description
      end

      def parse
        matched_message = message&.match message_regex

        _message, @type, @task_id, @task_description, @commit_description = matched_message.to_a
      end

      def warning_message
        "Please ensure your commit message has the following format:\n" +
          valid_message_format +
          "\nMore info: https://fuseuniversal.atlassian.net/wiki/spaces/FD/pages/354942977/Commit+message+formatting"
      end

      private

        def message_regex
          # Matching positions
          # 1 - type
          # 2 - task_id (optional, defaults to nil)
          # 3 - task_description
          # 4 - commit_description (optional, defaults to nil)
          /\A(#{type_regex}) (?:(#{task_id_regex}) )?(#{task_description_regex})(?:\n\n(#{commit_description_regex}))?\Z/m
        end

        def type_regex
          Regexp.union VALID_TYPES
        end

        def task_id_regex
          /[\d\w]+-[\d\w]+/
        end

        def strict_task_id_regex
          /([A-Z]+-[\d]+)/
        end

        def task_description_regex
          /[\w]+.*(?<!\n\n)/m
        end

        def commit_description_regex
          /[\w\d\s[:punct:]]+/m
        end

        def valid_message_format
          "\n    <type> <task_id> <task_description>\n\n    <commit_description>\n"
        end

        def validate_task_id_format
          errors.add(:task_id) if does_not_match_format?(task_id, strict_task_id_regex)
        end

        def validate_task_description_format
          errors.add(:task_description) if does_not_match_format?(task_description, task_description_regex)
        end

        def validate_commit_description_format
          errors.add(:commit_description) unless commit_description.start_with?("\n\n")
        end

        def skip_validations?
          message&.start_with?('Merge branch')
        end

        def does_not_match_format? string, format
          string !~ /\A#{format}\z/
        end
    end
  end
end
