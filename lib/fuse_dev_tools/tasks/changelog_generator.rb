require 'fuse_dev_tools/lib/git_hub'
require 'fuse_dev_tools/lib/changelog_builder'

module FuseDevTools
  module Tasks
    class ChangelogGenerator < Thor
      desc :preview, 'Previews changelog entries based on GitHub history'
      option 'bump', desc: 'Bump: patch, minor, major', default: 'patch'
      option 'repo', desc: 'Repo name if different than current'
      def preview
        @repo ||= options['repo']
        puts format_changelog options['bump'].to_sym
      end

      desc :create, 'Creates changelog entries and prepends to CHANGELOG.MD'
      option 'bump', desc: 'Bump: patch, minor, major', default: 'patch'
      def create
        return unless File.exist? changelog_file

        write_changelog_file(prepended_changelog_lines)
      end

      desc :next_version, 'Prints out next bumped version'
      option 'bump', desc: 'Bump: patch, minor, major', default: 'patch'
      option 'repo', desc: 'Repo name if different than current'
      def next_version
        @repo ||= options['repo']
        puts next_version? options['bump'].to_sym
      end

      desc :previous_version, 'Prints out previous/current version'
      option 'repo', desc: 'Repo name if different than current'
      def previous_version
        @repo ||= options['repo']
        puts previous_version?
      end

      no_tasks do
        def org
          'Fuseit'
        end

        def repo
          @repo ||= %x(basename -s .git `git config --get remote.origin.url`).strip
        end

        def next_version? bump
          GitHub.next_version? org, repo, bump
        end

        def previous_version?
          GitHub.previous_version? org, repo
        end

        def commits
          GitHub.comparison_message_commits org, repo, "v#{previous_version?}", 'HEAD'
        end

        def format_changelog bump
          builder = ChangelogBuilder.new commits
          next_ver = next_version? bump

          "## #{next_ver} - #{Time.zone.today}\n\n#{builder.build}\n\n"
        end

        def changelog_file
          'CHANGELOG.MD'
        end

        def prepended_changelog_lines
          f = File.open changelog_file, 'r+'
          lines = f.readlines
          f.close

          [format_changelog(options['bump'].to_sym)] + lines
        end

        def write_changelog_file lines
          output = File.new changelog_file, 'w'
          lines.each { |line| output.write line }
          output.close
        end
      end
    end
  end
end
