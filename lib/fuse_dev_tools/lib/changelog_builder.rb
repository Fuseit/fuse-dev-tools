require 'active_support/core_ext/string'

class ChangelogBuilder
  JIRA_URL = 'https://fuseuniversal.atlassian.net'.freeze

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
        categorize_by_message_type formatted_message, message.split(' ').first
      end
    end

    def format_commit_message line, sha
      split_line = line.split(' ')
      _, jira_ticket = split_line.shift(2)
      "* [#{jira_ticket}](#{JIRA_URL}/browse/#{jira_ticket}): #{split_line.join(' ')} #{sha}"
    end

    def categorize_by_message_type message, type
      case type
      when 'feature'
        categorized[:features] << message
      when 'hotfix', 'fix'
        categorized[:fixes] << message
      when 'chore', 'refactor', 'test'
        categorized[:technical_improvements] << message
      else
        categorized[:not_categorised] << message
      end
    end
end
