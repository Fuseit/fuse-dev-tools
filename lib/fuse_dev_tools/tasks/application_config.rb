require 'thor'
require 'fuse_dev_tools/application_config'

module FuseDevTools
  module Tasks
    class ApplicationConfig < Thor
      desc :download, 'Downloads config file from AWS S3'
      option 'config_name', desc: 'Config name', default: 'application.yml'
      option 'application_name', desc: 'Application name', default: 'fuse_dev'
      option 'bucket_region', desc: 'AWS S3 bucket region', default: 'eu-west-1'
      option 'bucket_name', desc: 'AWS S3 bucket name', default: 'fuse-devops'
      option 'download_dir', desc: 'Local directory to download the config', default: 'config'
      def download
        path = File.join options['download_dir'], options['config_name']

        if File.exist? path
          return unless yes?("Config file #{path} is already exists. Override? (y/N)")
        end

        config = build_application_config options
        download_options = build_download_options options

        puts "Config was saved to #{path}" if config.download(download_options)
      end

      no_tasks do
        def build_application_config options
          FuseDevTools::ApplicationConfig.new \
            bucket_region: options['bucket_region'],
            bucket_name: options['bucket_name']
        end

        def build_download_options options
          {
            name: options[:config_name],
            application: options[:application_name],
            destination: options[:download_dir]
          }
        end
      end
    end
  end
end
