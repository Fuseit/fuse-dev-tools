require 'fuse_dev_tools/git_tools/commit_message'
require 'fuse_dev_tools/git_tools/commit_checker'
require 'fuse_dev_tools/shared_methods/git_methods'
require 'active_support'
require 'rainbow'
require 'thor'

module FuseDevTools
  module Tasks
    module GitCommands
      module CommitMessages
        extend ::ActiveSupport::Concern

        include FuseDevTools::SharedMethods::GitMethods

        included do
          desc :validate_commit_message, 'Ensure commit message is correct syntax'
          def validate_commit_message
            latest_commit_message = commit_messages.first
            say Rainbow("Validating commit message:\n").yellow
            say Rainbow(latest_commit_message.to_s).faint
            say ''
            validator = ::FuseDevTools::GitTools::CommitMessage.new(message: latest_commit_message).parse
            if validator.valid?
              say Rainbow('Commit message valid!').green
              exit 0
            else
              say Rainbow(validator.warning_message).yellow
              say Rainbow('Commit message invalid!').red
              exit 1
            end
          end
        end
      end
    end
  end
end
