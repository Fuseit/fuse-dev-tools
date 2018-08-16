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

## Development

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Documentation

Documentation for this project can be found on [Confluence](https://fuseuniversal.atlassian.net/wiki/spaces/FD/pages/440795149/FuseDevTools).
