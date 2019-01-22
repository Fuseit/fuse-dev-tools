lib = File.expand_path 'lib', __dir__
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fuse_dev_tools/version'

Gem::Specification.new do |spec|
  spec.name = 'fuse-dev-tools'
  spec.version = FuseDevTools::VERSION
  spec.authors = ['Ivan Garmatenko', 'Baron Bloomer']
  spec.email = %w[igarmatenko@sphereinc.com baron.bloomer@fuseuniversal.com]

  spec.summary = 'Gem contains dev tools and tasks'
  spec.description = 'Gem contains dev tools and tasks'
  spec.homepage = 'https://github.com/Fuseit/fuse-dev-tools'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = 'https://github.com/Fuseit/fuse-dev-tools'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f =~ /^\.(.*)/
    f.match %r{^(test|spec|features)/}
  end

  spec.require_paths = %w[lib]
  spec.executables = %w[fuse-dev-tools]

  spec.add_dependency 'activemodel'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'aws-sdk-s3'
  spec.add_dependency 'git'
  spec.add_dependency 'pry', '~> 0.11'
  spec.add_dependency 'rainbow'
  spec.add_dependency 'rubocop', '~> 0.56'
  spec.add_dependency 'rubocop-rspec', '>= 1.25'
  spec.add_dependency 'thor', '~> 0.2'
  spec.add_dependency 'virtus'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.3'
  spec.add_development_dependency 'rubocop-junit-formatter', '~> 0.1'
end
