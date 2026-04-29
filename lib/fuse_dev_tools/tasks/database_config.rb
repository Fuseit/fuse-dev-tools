require 'rbconfig'
require 'fuse_dev_tools/tasks/base'

module FuseDevTools
  module Tasks
    class DatabaseConfig < Base
      source_root File.expand_path('../templates', __dir__)

      desc :copy, 'Copy database config'
      def copy
        template 'database.yml.erb', 'config/database.yml',
                 application: detect_application,
                 socket: detect_mysql_socket
      end

      private

        def detect_mysql_socket
          linux? ? '/var/run/mysqld/mysqld.sock' : '/tmp/mysql.sock'
        end

        def linux?
          RbConfig::CONFIG['host_os'].downcase.include? 'linux'
        end

        def detect_application
          git_repository_name || ask('Please provide application name:')
        end

        def git_repository_name
          %x(basename -s .git `git config --get remote.origin.url`).strip
        end
    end
  end
end
