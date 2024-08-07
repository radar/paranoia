source 'https://rubygems.org'

sqlite = ENV['SQLITE_VERSION']

if sqlite
  gem 'sqlite3', sqlite, platforms: [:ruby]
else
  # Do not use sqlite3 v2.0.0 or later because it is not compatible with the current Rails version.
  # We can remove this constraint when Rails 7.2 is released.
  # See https://github.com/rails/rails/pull/51592 and https://github.com/rails/rails/blob/v7.2.0.rc1/activerecord/CHANGELOG.md#rails-720beta1-may-29-2024
  gem 'sqlite3', "~> 1.4", platforms: [:ruby]
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

if RUBY_ENGINE == 'rbx'
  platforms :rbx do
    gem 'rubinius-developer_tools'
    gem 'rubysl', '~> 2.0'
    gem 'rubysl-test-unit'
  end
end

rails = ENV['RAILS'] || '~> 6.0.4'

if rails == 'edge'
  gem 'rails', github: 'rails/rails'
else
  gem 'rails', rails
end

# Specify your gem's dependencies in paranoia.gemspec
gemspec
