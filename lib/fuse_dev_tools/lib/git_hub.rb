require 'semantic'
require 'octokit'

class GitHub
  def self.client
    @client ||= Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'] || raise('Missing Github access token'))
  end

  def self.previous_release_version username, repo
    latest_release = client.latest_release("#{username}/#{repo}")[:name]
    latest_release.slice!(0)
    latest_release.gsub!(/ .*$/, '')
    Semantic::Version.new(latest_release)
  end

  def self.next_release_version username, repo, bump
    next_version = previous_release_version username, repo
    case bump
    when :pre
      next_version.pre = next_pre_version(next_version)
    when :patch
      next_version.patch += 1
      next_version.pre = nil
    when :minor
      next_version.minor += 1
      next_version.patch = 0
      next_version.pre = nil
    when :major
      next_version.major += 1
      next_version.minor = 0
      next_version.patch = 0
      next_version.pre = nil
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

  def self.next_pre_version next_version
    _, pre_number = next_version.identifiers(next_version.pre) if next_version.pre
    next_pre_number = pre_number ? pre_number + 1 : 1
    "pre.#{next_pre_number}"
  end
end
