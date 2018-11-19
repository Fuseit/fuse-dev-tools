require 'fuse_dev_tools/shared_methods/git_methods'

module FuseDevTools
  module GitTools
    class CommitChecker
      include ::FuseDevTools::SharedMethods::GitMethods

      def changed_files earlier_commit_sha, latter_commit_sha
        git.diff(earlier_commit_sha, latter_commit_sha).entries.map(&:path)
      end

      def file_changed? earlier_commit_sha, latter_commit_sha, file_path
        changed_files(earlier_commit_sha, latter_commit_sha).include? file_path
      end

      def pull_request? branch_name = git.current_branch
        !%w[master dev hotfix-deploy].include?(branch_name) &&
          !branch_name.start_with?('feature-deploy-') &&
          !branch_name.start_with?('release')
      end
    end
  end
end
