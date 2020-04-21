require 'octokit'

class GithubFileCommitter
  def initialize(repo = 'ACronje/deploy-test', branch = 'master', access_token = ENV['GITHUB_ACCESS_TOKEN'])
    @repo = repo
    @branch = branch
    @github = Octokit::Client.new(access_token: access_token || raise('Missing Github access token'))
    @files = []
  end

  def add_file(file, content)
    @files.push(path: file, content: content)
  end

  def commit(message)
    last_commit_sha = last_commit
    last_tree = tree_for(last_commit_sha)
    tree_sha = create_tree(last_tree)
    new_commit_sha = create_commit(message, tree_sha, last_commit_sha)
    response = update_branch(new_commit_sha)
    @files = []
    response
  end

  private

    def last_commit
      @github.ref(@repo, "heads/#{@branch}").object.sha
    end

    def tree_for(commit_sha)
      @github.git_commit(@repo, commit_sha).tree.sha
    end

    def create_tree(last_tree)
      new_tree = @files.map do |file|
        content = file.delete(:content)
        file.merge(mode: '100644', type: 'blob', sha: @github.create_blob(@repo, Base64.encode64(content), 'base64'))
      end
      @github.create_tree(@repo, new_tree, base_tree: last_tree).sha
    end

    def create_commit(message, tree_sha, parent)
      @github.create_commit(@repo, message, tree_sha, parent).sha
    end

    def update_branch(new_sha)
      @github.update_branch(@repo, @branch, new_sha)
    end
end
