require 'active_support'
require 'git'

module FuseDevTools
  module SharedMethods
    module GitMethods
      def commit_messages
        git.log.map(&:message)
      end

      def git
        @git ||= Git.open(Dir.pwd)
      end
    end
  end
end
