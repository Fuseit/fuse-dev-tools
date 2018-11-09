require 'fuse_dev_tools/git_tools/commit_message'
require 'fuse_dev_tools/git_tools/commit_checker'
require 'fuse_dev_tools/shared_methods/git_methods'
require 'active_support'
require 'colorize'
require 'thor'

module FuseDevTools
  module Tasks
    module GitCommands
      module PullRequests
        extend ::ActiveSupport::Concern

        include FuseDevTools::SharedMethods::GitMethods

        included do
          desc :validate_pull_request, 'Ensure pull requests conform to rules and requirements'
          def validate_pull_request
            exit 0 if skip_ensure_changelog_exclusion?

            current_branch_name = git.branches.select { |br| br.name == git.current_branch }.first
            parent = git.branch.name
            checker = ::FuseDevTools::GitTools::CommitChecker.new(parent, current_branch_name)
            if checker.file_changed?('CHANGELOG.md')
              say 'CHANGELOG changed detected! Please do not add a CHANGELOG entry in your Pull Request'.colorize(:red)
              exit 1
            else
              exit 0
            end
          end

          private

          def latest_commit_message
            commit_messages.first
          end

          def skip_ensure_changelog_exclusion?
            validator = ::FuseDevTools::GitTools::CommitMessage.new(message: latest_commit_message).parse
            validator.bump_version? || validator.merge_commit?
          end
        end
      end
    end
  end
end
