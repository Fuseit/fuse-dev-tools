# FuseDevTools

Gem contains dev tools and tasks

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fuse-dev-tools', git: 'git@github.com:Fuseit/fuse-dev-tools.git'
```

And then execute:

    $ bundle

## Usage

See binary for available tasks:
```
fuse-dev-tools --help
```

To use RuboCop configuration create `.rubocop.yml` with the following lines:
```yml
inherit_gem:
  fuse-dev-tools: lib/fuse_dev_tools/templates/.rubocop.yml
```

## Changelog generator

Generate a Github personal access token with read-only access to all repos [here](https://github.com/settings/tokens)

Example usage:
```
GITHUB_ACCESS_TOKEN=a9123012839018239123089123 fuse-dev-tools changelog_generator preview --repo FuseTube
```

## Creating a release

To create a release you must type in the command below using the arguments `-a` being the repository name from github you want to release 
and `-b` for the version increase of the application, which supports the values major, minor, patch and pre. 

Example usage:
`./bin/create-release -a fuse_courses -b patch`

## Development

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Documentation

Documentation for this project can be found on [Confluence](https://fuseuniversal.atlassian.net/wiki/spaces/FD/pages/440795149/FuseDevTools).
