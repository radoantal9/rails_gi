require 'simplecov'
require 'ffaker'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
#require 'paper_trail/frameworks/rspec'
require 'capybara/rails'
#require "sauce"
#require "sauce/capybara"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

require 'capybara/poltergeist'
require 'capybara-screenshot'
require 'capybara-screenshot/rspec'

Capybara.register_driver :poltergeist do |app|
  # For now we have to ignore JS errors because our plugins have JS errors
  Capybara::Poltergeist::Driver.new(app, {js_errors: false})
end

Capybara.default_driver = :rack_test
#Capybara.javascript_driver = :selenium
Capybara.javascript_driver = :poltergeist

Capybara.default_wait_time = 30
# Capybara.asset_host = "localhost:3000"

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include RequestHelpers, type: :feature
  config.include Capybara::DSL
  config.include Warden::Test::Helpers
  config.include Devise::TestHelpers, type: :controller

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Database cleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |spec|

    if spec.metadata[:js] || spec.metadata[:test_commit]
      # https://gist.github.com/moonfly/4950750
      # JS => run with PhantomJS that doesn't share connections => can't use transactions
      # deletion is often faster than truncation on Postgres - doesn't vacuum
      # no need to 'start', clean_with is sufficient for deletion
      # Devise Emails: devise-async sends confirmation on commit only! => can't use transactions
      puts "---> Starting spec DB"
      spec.run
      puts "---> Cleaning DB"
      DatabaseCleaner.clean_with (:truncation)
    else
      DatabaseCleaner.start
      spec.run
      DatabaseCleaner.clean

      begin
        ActiveRecord::Base.connection.send(:rollback_transaction_records, true)
      rescue
      end

    end

  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  Thread.current["PgSearch.enable_multisearch"] = false

  config.infer_spec_type_from_file_location!

  # Open screenshot
  config.after do |example|
    if example.metadata[:type] == :feature and example.exception.present?
      save_and_open_page
    end
  end

end

# Silent pp/ap
unless ENV['PP_ENABLED'].present?
  def pp(*args)
  end

  def ap(*args)
  end
end
