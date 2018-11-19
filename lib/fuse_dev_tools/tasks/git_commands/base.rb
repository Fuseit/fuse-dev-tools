require_relative 'commit_messages'
require_relative 'pull_requests'

module FuseDevTools
  module Tasks
    module GitCommands
      class Base < Thor
        include CommitMessages
        include PullRequests
      end
    end
  end
end
