# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.3"

gem "rails", "~> 7.1.3", ">= 7.1.3.4"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
gem "jsonapi-serializer"
gem "kaminari"
gem "pg"
gem "puma", ">= 5.0"
gem "sprockets-rails"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  gem "dotenv-rails"
  gem "rspec-rails", "~> 6.1.0"
end

group :development do
  gem "rubocop-rails"
  gem "rubocop-rspec"
end

group :test do
  gem "database_cleaner-active_record"
  gem "factory_bot_rails"
  gem "rspec-json_expectations"
end

gem "net-pop", github: "ruby/net-pop"
