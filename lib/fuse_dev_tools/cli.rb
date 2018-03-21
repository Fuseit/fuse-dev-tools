require 'thor'
Dir[File.join(__dir__, 'tasks', '*.rb')].each(&method(:require))

module FuseDevTools
  class CLI < Thor
    include Thor::Actions

    desc :init, 'Initialize config with AWS credentials'
    def init
      require 'fuse_dev_tools/config'

      if FuseDevTools::Config.exists?
        return unless yes?("Config file #{FuseDevTools::Config.filename} is already exists. Override? (y/N)")
      end

      say 'Please provide values for config parameters'

      config = {}
      FuseDevTools::Config::KEYS.each do |config_key|
        config[config_key] = ask config_key + ':'
      end

      create_file FuseDevTools::Config.filename, config.to_yaml
    end

    desc 'application_config COMMAND', 'Commands for application config'
    subcommand :application_config, FuseDevTools::Tasks::ApplicationConfig

    desc 'database_config COMMAND', 'Commands for database config'
    subcommand :database_config, FuseDevTools::Tasks::DatabaseConfig

    desc 'changelog_generator COMMAND', 'Commands for changelog'
    subcommand :changelog_generator, FuseDevTools::Tasks::ChangelogGenerator
  end
end
