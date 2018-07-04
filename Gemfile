source 'https://rubygems.org'

gem 'sqlite3', platforms: [:ruby]

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubysl-test-unit'
  gem 'rubinius-developer_tools'
end

rails = ENV['RAILS'] || '~> 5.2.0'

if rails == 'master'
  gem 'rails', git: 'https://github.com/rails/rails'
else
  gem 'rails', rails
end

# Specify your gem's dependencies in paranoia.gemspec
gemspec
