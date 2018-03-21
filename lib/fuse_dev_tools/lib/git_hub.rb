require 'github_api'
require 'semantic'

class GitHub
  def self.github
    @github ||= Github.new oauth_token: ENV['GITHUB_OAUTH_TOKEN']
  end

  def self.commit_status username, repo, commit_id
    status = github.repos.statuses.list username, repo, commit_id
    status.first.state
  end

  def self.last_commit username, repo, branch
    repos = github.repos.commits.list username, repo, sha: branch
    repos.first.sha
  end

  def self.this_last_commit? username, repo, branch, commit_id
    last_commit(username, repo, branch) == commit_id
  end

  def self.previous_version? username, repo
    list = github.repos.releases.list username, repo
    no_drafts = list.reject { |r| r[:draft] || r[:target_commitish] != 'master' }
    sorted = no_drafts.map { |e| e[:tag_name].delete('v') }
      .sort_by { |v| Semantic::Version.new v }
    Semantic::Version.new sorted.last
  end

  def self.next_version? username, repo, bump
    next_version = previous_version? username, repo
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
    github.repos.commits.compare username, repo, base, head
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
