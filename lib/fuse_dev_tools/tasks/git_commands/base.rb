require_relative 'commit_messages'

module FuseDevTools
  module Tasks
    module GitCommands
      class Base < Thor
        include CommitMessages
      end
    end
  end
end
