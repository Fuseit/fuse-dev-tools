require 'aws-sdk'
require 'pry'

module FuseDevTools
  class ApplicationConfig
    attr_accessor :access_key_id, :access_key_secret, :bucket_region, :bucket_name

    def initialize bucket_region:, bucket_name:
      require 'fuse_dev_tools/config'

      config = FuseDevTools::Config.load

      self.access_key_id     = config.opsworks_access_key_id
      self.access_key_secret = config.opsworks_secret_access_key
      self.bucket_region     = bucket_region
      self.bucket_name       = bucket_name
    end

    def download name:, destination:, application: nil
      path = File.join 'env-vars', application, name

      unless config_exists? path
        raise "#{name} file not found on S3!"\
              'Please ensure the following file exists at the S3 location: '\
              "#{bucket_name}/#{path}"
      end

      bucket_object(path).get response_target: File.join(destination, name)
    end

    private

      def bucket
        Aws.config.update region: bucket_region, credentials: access_credentials
        Aws::S3::Resource.new.bucket bucket_name
      end

      def access_credentials
        Aws::Credentials.new access_key_id, access_key_secret
      end

      def bucket_object path
        bucket.object path
      end

      def config_exists? path
        bucket_object(path).exists?
      end
  end
end