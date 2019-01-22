require 'fuse_dev_tools/git_tools/pull_request_validator'
require 'active_support'
require 'rainbow'
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
              say Rainbow('Pull request passed validation').green
              exit 0
            else
              say Rainbow('Your Pull Request is invalid! Please check the following errors:').red
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
                say Rainbow("- #{message}").red
              end
            end
        end
      end
    end
  end
end
