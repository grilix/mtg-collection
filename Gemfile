# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby '2.5.1'

gem 'cuba', '~> 3.8'
gem 'pg', '~> 0.21'
gem 'sequel', '~> 4.49'
gem 'bcrypt', '~> 3.1'
gem 'rack-console', '~> 1.3'
gem 'rack-cors', '~> 1.0'
gem 'yajl-ruby', '~> 1.3'
gem 'rack-jwt', '~> 0.3'

group :production do
  gem 'puma', '~> 3.12'
end

group :development, :test do
  gem 'shotgun', '~> 0.9'
  gem 'byebug', '~> 9.0'
  gem 'timecop', '~> 0.9'
end

group :test do
  gem 'fabrication', '~> 2.16'
  gem 'rspec', '~> 3.6'
  gem 'capybara', '~> 2.15'
  gem 'vcr', '~> 3.0'
  gem 'webmock', '~> 3.0'
end
