require 'semantic'
require 'octokit'

class GitHub
  def self.client
    @client ||= Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'] || raise('Missing Github access token'))
  end

  def self.previous_release_version username, repo
    # for now we use tags since releases are not up-to-date
    tags = client.tags("#{username}/#{repo}")
    tag_names = tags.map { |tag| tag[:name] }
    version_tags = tag_names.select { |tag| tag =~ /^v[0-9]/i }
    version_numbers = version_tags.map { |tag| tag.sub(/^v/i, '') }
    semvers = version_numbers.map { |version| Semantic::Version.new(version) }
    semvers.max
  end

  def self.next_release_version username, repo, bump
    next_version = previous_release_version username, repo
    case bump
    when :patch
      next_version.patch += 1
    when :minor
      next_version.minor += 1
      next_version.patch = 0
    when :major
      next_version.major += 1
      next_version.minor = 0
      next_version.patch = 0
    end
    "v#{next_version}"
  end

  def self.compare username, repo, base, head
    client.compare("#{username}/#{repo}", base, head)
  end

  def self.comparison_message_commits username, repo, base, head
    commits = compare(username, repo, base, head).commits
    commits.select! { |c| c.parents.length == 1 }
    commits.map do |c|
      {
        'sha' => c.sha[0..6],
        'message' => c.commit.message
      }
    end
  end

  def self.comparison_message_commits_count username, repo, base, head
    commits = compare(username, repo, base, head).commits
    commits.select! { |c| c.parents.length == 1 }
    commits.size
  end
end
