require 'fuse_dev_tools/tasks/base'
require_relative 'commit_messages'
require_relative 'pull_requests'

module FuseDevTools
  module Tasks
    module GitCommands
      class Base < FuseDevTools::Tasks::Base
        include CommitMessages
        include PullRequests
      end
    end
  end
end
