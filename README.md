# Fuse::Dev::Tools

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

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fuse-dev-tools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Fuse::Dev::Tools project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/fuse-dev-tools/blob/master/CODE_OF_CONDUCT.md).
