source 'https://rubygems.org'

sqlite = ENV['SQLITE_VERSION']

if sqlite
  gem 'sqlite3', sqlite, platforms: [:ruby]
else
  # Rails 8.0 requires sqlite3 2.x
  gem 'sqlite3', ENV['RAILS']&.start_with?('~> 8') ? '~> 2.1' : '~> 1.4', platforms: [:ruby]
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

rails = ENV['RAILS'] || '~> 6.1.0'

if rails == 'edge'
  gem 'rails', github: 'rails/rails'
else
  gem 'rails', rails
end

# Specify your gem's dependencies in paranoia.gemspec
gemspec
