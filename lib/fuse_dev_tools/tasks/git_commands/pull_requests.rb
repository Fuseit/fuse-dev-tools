require 'fuse_dev_tools/git_tools/pull_request_validator'
require 'active_support'
require 'colorize'
require 'thor'

module FuseDevTools
  module Tasks
    module GitCommands
      module PullRequests
        extend ::ActiveSupport::Concern

        included do
          desc :validate_pull_request, 'Ensure pull requests conform to rules and requirements'
          def validate_pull_request
            if validator.valid?
              say 'Pull request passed validation'.colorize(:green)
              exit 0
            else
              say 'You Pull Request is invalid! Please check the following errors:'.colorize(:red)
              say_errors validator
              exit 1
            end
          end

          private

            def validator
              @validator ||= ::FuseDevTools::GitTools::PullRequestValidator.new
            end

            def say_errors object
              object.errors.full_messages.each do |message|
                say "- #{message}".colorize(:red)
              end
            end
        end
      end
    end
  end
end
