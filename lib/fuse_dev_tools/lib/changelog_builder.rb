require 'active_support/core_ext/string'

class ChangelogBuilder
  def initialize commits
    @commits = commits
  end

  def build
    categorize_commits
    mapped = categorized.map do |category, commits|
      next if commits.empty?
      "### #{category.to_s.humanize}\n\n#{commits.join("\n")}\n"
    end
    mapped.join("\n")
  end

  private

    attr_accessor :commits

    def categorized
      @categorized ||= {
        not_categorised: [],
        features: [],
        fixes: [],
        technical_improvements: []
      }
    end

    def categorize_commits
      commits.each do |commit|
        message = commit['message']

        formatted_message = format_commit_message message, commit['sha']

        case message.split(' ').first
        when 'feature'
          categorized[:features] << formatted_message
        when 'hotfix', 'fix'
          categorized[:fixes] << formatted_message
        when 'chore', 'refactor', 'test'
          categorized[:technical_improvements] << formatted_message
        else
          categorized[:not_categorised] << formatted_message
        end
      end
    end

    def format_commit_message message, sha
      '* ' + message.split(' ').drop(1).join(' ') + " ##{sha}"
    end
end
