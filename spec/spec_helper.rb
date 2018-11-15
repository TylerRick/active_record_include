require 'pp'
require 'byebug'
require 'pry'

require 'bundler/setup'
require 'normalizy'
require 'active_record_include'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# ActiveRecord
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Support
$LOAD_PATH << "#{__dir__}/support/models"
require "#{__dir__}/support/schema"
Dir["#{__dir__}/support/**/*.rb"].sort.each do |file|
  next if file.include?('/concerns/')
  require file
end
