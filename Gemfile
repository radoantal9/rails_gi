source 'https://rubygems.org'
gem 'dotenv-rails', :groups => [:development, :test]

gem 'rails', '4.1.10'
gem 'protected_attributes'

# server
gem 'thin', :group => :development
gem 'whenever', :require => false
gem 'delayed_job_active_record'
gem 'daemons'
gem 'unicorn', :group => [:staging, :production]
gem 'unicorn-worker-killer', :group => [:staging, :production]

# logging and monitoring
gem 'newrelic_rpm'
gem 'airbrake'
gem 'pghero'

# cache
gem 'dalli-elasticache'
gem 'cache_digests'

# data
gem 'pg'
gem 'pg_search'
gem 'foreigner'
gem 'paper_trail', '>= 3.0.0.beta1'
gem 'simple_enum', '~> 1.6'
gem 'has_scope'
gem 'attribute_normalizer'
gem 'email_validator'
gem 'acts_as_list'
gem 'role_model'
gem 'state_machine' , github: 'seuros/state_machine'
gem 'carrierwave'
gem 'acts_as_commentable_with_threading'
gem 'awesome_nested_set'
gem 'paranoia', '~> 2.0'

# user
gem 'cancancan', '~> 1.7'
gem 'devise', '~> 3.0'
gem 'omniauth'
gem 'omniauth-google-oauth2'

# assets
gem 'non-stupid-digest-assets'
gem 'sass-rails', '~> 4.0'
gem 'uglifier', '>= 1.3'
gem 'coffee-rails', '~> 4.0'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.2'
gem 'autoprefixer-rails'
gem 'font-awesome-rails'
gem 'fancybox-rails'
gem 'select2-rails'
gem 'momentjs-rails', '~> 2.8.3'
gem 'haml-rails'
gem 'backbone-on-rails'
gem 'marionette-rails'
gem 'haml_coffee_assets'
gem 'js-routes'

# views
gem 'simple_form', '~> 3.1.0.rc1'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'redactor-rails', '~> 0.4.5'
gem "codemirror-rails"
gem 'wice_grid'
gem 'swf_fu'
gem 'flash_cookie_session'
gem 'google-analytics-rails'
gem 'nested_form'
gem 'chart-js-rails'
gem 'chartkick'
gem 'groupdate'

# mail
gem 'letter_opener'
gem 'mandrill-api', '~> 1.0.53'

# misc
# gem 'wkhtmltopdf-binary', github: 'pallymore/wkhtmltopdf-binary'
gem 'wkhtmltopdf-binary-edge', '~> 0.12.2.1'
gem 'wicked_pdf'
gem 'mini_magick'
gem 'redcarpet'
gem 'nokogiri'
gem 'rubyzip'
gem 'standard_deviation'
gem 'roadie', '~> 2.4'
gem 'oj'
gem 'fast_blank'
gem 'inherited_resources'
gem 'fog'
gem 'rabl'

# dev
gem 'awesome_print'
group :development, :test do
  #gem 'debugger'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem "rspec-rails", '~> 3.2.1'
  gem 'simplecov', :require => false
  gem "parallel_tests"
  gem 'guard-rspec'
  gem 'rb-fsevent' if `uname` =~ /Darwin/

  gem 'sauce', :require => false
  gem 'sauce-connect' , :require => false
  gem 'sauce-cucumber', :require => false

  gem "capybara"
  gem 'cucumber-rails', :require => false
  gem 'capybara-screenshot'
  gem 'launchy'
  gem 'poltergeist', '~> 1.5'
  gem 'selenium-webdriver'
  gem 'pdf-reader'

  gem "factory_girl_rails"
  gem "ffaker"
  gem "database_cleaner"
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', '~> 3.2.0'
  gem 'capistrano-rails'
  gem 'quiet_assets'
  gem 'mail_view', '~> 2.0.4'
end

group :development, :staging do
  gem 'rack-mini-profiler', :require => false
end

# upgrades
# gem 'rails4_upgrade'
# gem 'arel_converter'
# gem 'actionpack-action_caching'
# gem 'actionpack-page_caching'
# gem 'actionpack-xml_parser'
# gem 'actionview-encoded_mail_to'
# gem 'activerecord-session_store'
# gem 'activeresource'
# gem 'rails-observers'
# gem 'rails-perftest'
