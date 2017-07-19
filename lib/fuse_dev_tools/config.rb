require 'yaml'

module FuseDevTools
  class Config
    KEYS = %w(OPSWORKS_ACCESS_KEY_ID OPSWORKS_SECRET_ACCESS_KEY)

    def self.load
      new YAML.load File.new(filename)
    end

    def self.filename
      File.join Dir.home, '.fuse-cli-config.yaml'
    end

    def self.exists?
      File.exists? filename
    end

    def initialize config
      @config = config
    end

    KEYS.each do |config_key|
      define_method config_key.downcase do
        @config[config_key]
      end
    end
  end
end