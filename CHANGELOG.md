## v0.7.1

### Technical improvements

* PLAT-1030 Replace `colorize` with `rainbow` gem


## v0.7.0

### Features

* Add Changelog validation for a pull request merge


## v0.6.3

### Technical improvements

* Remove extra rails cop when running rubocop on circleci
* Broken CircleCI bundler caching

### Bugfixes

* Fix updating aws config credentials for accessing a bucket


## v0.6.2

### Features

* Disable RSpec/DescribeClass cop for tasks, requests and view specs

### Technical improvements

* Remove unused rubocop-rspec-focused dependency

### Bugfixes

* Fix CommitMessage validation to pass a merge message with a type prefix
* Add CommitMessage validation for a pull request merge


## v0.6.1

### Bugfixes

* Fix CommitMessage validation to read from working directory


## v0.6.0

### Features

* Add CommitMessage validation


## v0.5.0

### Features

* CS-36 Add default Rubocop config for use in projects


## v0.3.0

### Features

* SAS-83 Task to copy MySQL configuration from fuse-dev-tools
