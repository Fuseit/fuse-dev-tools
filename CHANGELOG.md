## v0.9.0

### Technical improvements

* Remove the use of the thor gem as a dependency and lock rack dev dependency version


## v0.8.0

### Technical improvements

* PD-10038 upgrade rubocop


## v0.7.4

### Technical improvements

* Update Ruby to 2.4


## v0.7.3

### Features

* Release creation script accepts branches other than master
* PD-1533 Add pre release bump
* PD-000 Us releases instead of tags when checking for latest release
* FUSE-1270 Put both scripts in one place
* FUSE-1720 Automate tagging and releasing
* FUSE-1593 Changelog generator

### Technical improvements

* Document target branch flags
* FUSE-1000 Update README.md with instructions on creating a release
* SAM-1 Replace $1 and $2 with local variables
* FUSE-1729 Update CHANGELOG.md and VERSION with new release version
* FUSE-1726 changelog commit sha to be linkable in github releases

### Bugfixes

* DEV-01 prepend v to release tag
* SAM-1 Prepend tag version with v
* FIX-1797 Change formatting to use JIRA links instead of just the ticket


## v0.7.2

### Features

* PLAT-1270 Add Airbrake

### Technical improvements

* modify CHANGELOG error message to help solve specific cases

### Bugfixes

* FIX-1655 Fix flaky PR validator
* Fix rubocop issues
* PLAT-896 Fix parent commit sha


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
