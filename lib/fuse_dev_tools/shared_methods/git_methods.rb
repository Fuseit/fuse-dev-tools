require 'active_support'
require 'git'

module FuseDevTools
  module SharedMethods
    module GitMethods
      private

        def commit_messages
          git.log.map(&:message)
        end

        def git
          @git = Git.open(FuseDevTools.root)
        end
    end
  end
end
