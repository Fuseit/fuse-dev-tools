require 'fuse_dev_tools/tasks/application_config'
require 'fuse_dev_tools/tasks/database_config'
require 'fuse_dev_tools/tasks/git_commands/base'
require 'fuse_dev_tools/tasks/base'
Dir[File.join(__dir__, 'tasks', '*.rb')].sort.each(&method(:require))

module FuseDevTools
  class CLI < Tasks::Base
    desc :init, 'Initialize config with AWS credentials'
    def init
      require 'fuse_dev_tools/config'

      if FuseDevTools::Config.exists?
        return unless yes?("Config file #{FuseDevTools::Config.filename} is already exists. Override? (y/N)")
      end

      say 'Please provide values for config parameters'

      config = {}
      FuseDevTools::Config::KEYS.each do |config_key|
        config[config_key] = ask "#{config_key}:"
      end

      create_file FuseDevTools::Config.filename, config.to_yaml
    end

    desc :application_config, 'Commands for application config'
    def application_config
      run_subcommand Tasks::ApplicationConfig
    end

    desc :database_config, 'Commands for database config'
    def database_config
      run_subcommand Tasks::DatabaseConfig
    end

    desc :git, 'Commands for git'
    def git
      run_subcommand Tasks::GitCommands::Base
    end

    desc :changelog_generator, 'Commands for changelog'
    def changelog_generator
      run_subcommand Tasks::ChangelogGenerator
    end

    def start argv = []
      @subcommand_arguments = argv[1..-1] || []
      super(proxy_command?(argv.first) ? [argv.first] : argv)
    end

    private

      def proxy_command? command
        %w[application_config database_config git changelog_generator].include? command.to_s
      end

      def run_subcommand command_class
        command_class.start(subcommand_arguments)
      end

      def subcommand_arguments
        @subcommand_arguments || []
      end
  end
end
