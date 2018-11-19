require 'fuse_dev_tools/git_tools/commit_checker'
require 'active_support'
require 'git'

module FuseDevTools
  module SharedMethods
    module GitMethods
      def commit_messages
        git.log.map(&:message)
      end

      def latest_commit_message
        commit_messages.first
      end

      def commit_checker
        @commit_checker = ::FuseDevTools::GitTools::CommitChecker.new
      end

      def git
        @git ||= Git.open(Dir.pwd)
      end
    end
  end
end
