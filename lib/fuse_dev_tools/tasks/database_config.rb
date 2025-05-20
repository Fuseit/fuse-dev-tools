require 'rbconfig'
require 'thor'

module FuseDevTools
  module Tasks
    class DatabaseConfig < Thor
      include Thor::Actions

      def self.source_root
        File.expand_path '../templates', __dir__
      end

      desc :copy, 'Copy database config'
      def copy
        template 'database.yml.erb', 'config/database.yml',
                 application: detect_application,
                 socket: detect_mysql_socket
      end

      no_tasks do
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
end
