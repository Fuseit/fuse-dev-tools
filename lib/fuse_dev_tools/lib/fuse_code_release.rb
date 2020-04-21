require_relative 'changelog_builder'
require_relative 'github_file_committer'
require_relative 'git_hub'


class FuseCodeRelease
  def initialize project, bump
    @project = project
    @bump = bump
    @client = GitHub.client
  end

  def call &confirmation_proc
    # #next version
    new_version = next_release_version
    #changelog

    formatted_commits = generate_formatted_commits_for_changelog
    changelog_updates = format_changelog_updates(new_version, formatted_commits)

    if confirmation_proc
      confirmation_message = "The following changes will be released\n\nGithub project:\n#{github_project}\n\nVersion:\n#{new_version}\n\nNew changelog entry:\n#{changelog_updates}"
      return unless confirmation_proc.call(confirmation_message)
    end

    previous_changelog = fetch_existing_changelog
    new_changelog = changelog_updates + previous_changelog


    # here we should ask for confirmation to continue

    file_commit_sha = commit_changelog_and_version(new_changelog, new_version).object.sha
    

    tag_name = new_version
    create_annotated_tag(tag_name, file_commit_sha)
    create_github_release(tag_name, formatted_commits)
    create_release_branch(file_commit_sha, new_version)
  end

  private

    def changelog_file
      'CHANGELOG.md'
    end

    def version_file
      'VERSION'
    end

    def organisation
      'ACronje'
    end

    def github_project
      "#{organisation}/#{@project}"
    end

    def commits_since_last_version
      GitHub.comparison_message_commits organisation, @project, previous_release_version, 'HEAD'
    end

    def previous_release_version
      "v#{GitHub.previous_release_version(organisation, @project)}"
    end

    def generate_formatted_commits_for_changelog
      ChangelogBuilder.new(commits_since_last_version).build
    end

    def format_changelog_updates version, formatted_commits 
      "## #{version} - #{Time.now}\n\n#{formatted_commits}\n\n"
    end

    def next_release_version
      GitHub.next_release_version organisation, @project, @bump
    end

    def fetch_existing_changelog
      Base64.decode64(@client.contents(github_project, path: changelog_file).content)
    end

    def commit_changelog_and_version changelog, version
      file_committer = GithubFileCommitter.new(github_project)
      file_committer.add_file('CHANGELOG.md', changelog)
      file_committer.add_file('VERSION', "#{version}\n")
      file_committer.commit("chore Bump version to #{version}")
    end

    def create_annotated_tag tag_name, commit_sha
      # tag_commit_sha = @client.create_tag(github_project, tag_name, "Release #{tag_name}", commit_sha, "commit", username, email, date).sha
      options = { tag: tag_name, message: "Release #{tag_name}", object: commit_sha, type: "commit" }
      tag_commit_sha = @client.post("#{Octokit::Repository.path github_project}/git/tags", options).sha
      @client.create_ref(github_project, "tags/#{tag_name}", tag_commit_sha)
    end

    def create_github_release tag_name, release_note
      @client.create_release(github_project, tag_name, { name: tag_name, body: release_note.strip })
    end

    def create_release_branch commit_sha, version
      @client.create_ref(github_project, "heads/#{version}", commit_sha)
    end
end
