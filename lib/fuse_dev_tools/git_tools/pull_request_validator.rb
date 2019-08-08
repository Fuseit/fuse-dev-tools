require 'fuse_dev_tools/git_tools/commit_message'
require 'fuse_dev_tools/git_tools/commit_checker'
require 'fuse_dev_tools/shared_methods/git_methods'
require 'active_model'

module FuseDevTools
  module GitTools
    class PullRequestValidator
      include ::ActiveModel::Validations
      include ::FuseDevTools::SharedMethods::GitMethods

      validate :validate_changelog_exclusion, unless: :skip_ensure_changelog_exclusion?

      private

        def validate_changelog_exclusion
          current_commit = git.gcommit(git.current_branch)
          parent = git.log.drop_while { |object| object.name.include? git.current_branch }.first
          return unless commit_checker.file_changed?(parent.sha, current_commit.sha, 'CHANGELOG.md')

          errors.add(:base, error_message_for(current_commit, parent))
        end

        def skip_ensure_changelog_exclusion?
          commit_message_info.bump_version_commit? ||
            commit_message_info.merge_commit? ||
            !commit_checker.pull_request?
        end

        def commit_checker
          @commit_checker ||= ::FuseDevTools::GitTools::CommitChecker.new
        end

        def commit_message_info
          @commit_message_info ||= ::FuseDevTools::GitTools::CommitMessage.new(message: latest_commit_message) \
            .parse
        end

        def error_message_for current_commit, parent_commit
          <<~HEREDOC
          CHANGELOG change detected! Please do not add a CHANGELOG entry in your Pull Request.
          Branch might be behind master making the changelog look different, try rebasing.

          Commit SHA: #{current_commit.sha}
          Parent SHA: #{parent_commit.sha}
          Changelog diff:
          #{changelog_diff(parent_commit.sha, current_commit.sha)}
          HEREDOC
        end

        def changelog_diff earlier_commit_sha, latter_commit_sha
          git.diff(earlier_commit_sha, latter_commit_sha) \
            .entries.select{ |e| e.path == 'CHANGELOG.md' } \
            .first&.patch || '<No CHANGELOG.md patch found>'
        end
    end
  end
end
