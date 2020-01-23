require 'bundler/setup'
require 'fuse_dev_tools'
require 'rspec/its'
require 'vcr'
require 'webmock'
require 'support/stream_capture_helper'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include StreamCaptureHelper
end
