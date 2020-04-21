require_relative '../lib/fuse_code_release'

module FuseDevTools
  module Tasks
    class ReleaseGenerator < Thor
      desc :release, 'Create a new code release for an application'
      option 'bump', desc: 'Bump: patch, minor, major', default: 'patch'
      option 'repo', desc: 'Repo name', required: true
      def release
        FuseCodeRelease.new(options['repo'], options['bump'].to_sym).call do |change_message|
          yes?("#{change_message}\nContinue? (y/N)")
        end
      end
    end
  end
end
