require "bundler/setup"

if ENV['CI']
  require 'codeclimate-test-reporter'
  SimpleCov.start do
    #add_filter '/spec/'
  end
end

require "hrr_rb_ssh"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:example) do
    HrrRbSsh::Logger.uninitialize
  end
end
