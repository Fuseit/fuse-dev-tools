require 'open3'
require 'rbconfig'
require 'tmpdir'
require 'yaml'

RSpec.describe 'CLI contracts', :aggregate_failures do
  let(:repo_root) { File.expand_path('../..', __dir__) }
  let(:cli_executable) { File.join(repo_root, 'bin', 'fuse-dev-tools') }

  def run_cli(*args, chdir: repo_root, env: {}, stdin: '')
    command = [RbConfig.ruby, cli_executable, *args]
    Open3.capture3(env, *command, stdin_data: stdin, chdir: chdir)
  end

  def setup_git_repo!(path, remote_url:)
    _stdout, _stderr, status = run_command(%w[git init], chdir: path)
    raise 'Failed to initialize git repo' unless status.success?

    _stdout, _stderr, status = run_command(['git', 'remote', 'add', 'origin', remote_url], chdir: path)
    raise 'Failed to set git remote origin' unless status.success?
  end

  def run_command(command, chdir:)
    stdout, stderr, status = Open3.capture3(*command, chdir: chdir)
    [stdout, stderr, status]
  end

  describe 'help output contracts' do
    it 'shows top-level commands' do
      stdout, _stderr, status = run_cli('--help')

      expect(status.exitstatus).to eq(0)
      expect(stdout).to include('application_config')
      expect(stdout).to include('database_config')
      expect(stdout).to include('git')
      expect(stdout).to include('changelog_generator')
    end

    it 'shows expected command entries for subcommands' do
      {
        %w[git --help] => %w[validate_commit_message validate_pull_request],
        %w[application_config --help] => %w[download],
        %w[database_config --help] => %w[copy],
        %w[changelog_generator --help] => %w[preview create next_version previous_version]
      }.each do |argv, expected_commands|
        stdout, _stderr, status = run_cli(*argv)
        expect(status.exitstatus).to eq(0)
        expected_commands.each do |command_name|
          expect(stdout).to include(command_name)
        end
      end
    end

    it 'keeps key option names discoverable' do
      stdout, _stderr, status = run_cli('application_config', 'download', '--help')

      expect(status.exitstatus).to eq(0)
      expect(stdout).to match(/--download[_-]dir/)
      expect(stdout).to match(/--config[_-]name/)
      expect(stdout).to match(/--application[_-]name/)
    end
  end

  describe 'error handling contracts' do
    it 'returns a helpful error for unknown options' do
      stdout, stderr, status = run_cli('application_config', 'download', '--not-a-real-option', 'value')

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include('Unknown option: --not-a-real-option')
      expect(stdout).to include('Usage: download [options]')
    end

    it 'returns a helpful error for missing option values' do
      stdout, stderr, status = run_cli('application_config', 'download', '--download_dir')

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include('Missing value for --download_dir')
      expect(stdout).to include('Usage: download [options]')
    end
  end

  describe 'interactive and file side-effect contracts' do
    it 'creates a config file for init command' do
      Dir.mktmpdir('fuse-dev-tools-home-') do |tmp_home|
        stdout, _stderr, status = run_cli(
          'init',
          env: { 'HOME' => tmp_home },
          stdin: "key-id\nsuper-secret\n"
        )

        expect(status.exitstatus).to eq(0)
        expect(stdout).to include('Please provide values for config parameters')

        config_path = File.join(tmp_home, '.fuse-cli-config.yaml')
        expect(File).to exist(config_path)

        config = YAML.safe_load(File.read(config_path))
        expect(config).to include(
          'OPSWORKS_ACCESS_KEY_ID' => 'key-id',
          'OPSWORKS_SECRET_ACCESS_KEY' => 'super-secret'
        )
      end
    end

    it 'creates config/database.yml from template' do
      Dir.mktmpdir('fuse-dev-tools-project-') do |tmp_project|
        setup_git_repo!(tmp_project, remote_url: 'git@github.com:Fuseit/demo-app.git')

        _stdout, _stderr, status = run_cli('database_config', 'copy', chdir: tmp_project)

        expect(status.exitstatus).to eq(0)
        database_config_path = File.join(tmp_project, 'config', 'database.yml')
        expect(File).to exist(database_config_path)

        config = File.read(database_config_path)
        expect(config).to include('database: demo-app_development')
        expect(config).to include('database: demo-app_test')
        expect(config).to include('database: demo-app_production')
      end
    end
  end
end
