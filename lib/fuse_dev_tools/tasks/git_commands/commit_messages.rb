require 'fuse_dev_tools/git_tools/commit_message'
require 'fuse_dev_tools/shared_methods/git_methods'
require 'active_support'
require 'colorize'
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
            say "Validating commit message:\n".colorize(:yellow)
            say latest_commit_message.colorize(:light_black)
            say ''
            validator = ::FuseDevTools::GitTools::CommitMessage.new(message: latest_commit_message).parse
            if validator.valid?
              say 'Commit message is valid!'.colorize(:green)
              exit 0
            else
              say validator.warning_message.colorize(:yellow)
              say 'Commit message invalid!'.colorize(:red)
              exit 1
            end
          end
        end
      end
    end
  end
end
