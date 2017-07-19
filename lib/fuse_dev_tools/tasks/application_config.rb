require 'thor'

module FuseDevTools::Tasks
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

      config = FuseDevTools::ApplicationConfig.new \
        bucket_region: options['bucket_region'],
        bucket_name: options['bucket_name']

      download_options = {
        name: options[:config_name],
        application: options[:application_name],
        destination: options[:download_dir]
      }

      puts "Config was saved to #{path}" if config.download(download_options)
    end
  end
end