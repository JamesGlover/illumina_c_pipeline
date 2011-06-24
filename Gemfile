source 'http://rubygems.org'

gem 'compass', '>= 0.11.1'
gem 'formtastic', '~>1.2.3'
gem 'mysql2', '~>0.2.7'
gem 'rails', '~>3.0.7'
gem 'rake', '~>0.8.7'
gem 'state_machine', '~>1.0.1'
gem 'hashie', '~>1.0.0'

gem 'sequencescape-client-api',
  :git     => 'http://github.com/mattdenner/sequencescape-client-api.git',
  :branch  => 'pulldown_pipeline_thoughts',
  :require => 'sequencescape'
gem 'sanger_barcode',
  :git     => 'http://github.com/sanger/sanger_barcode.git',
  :branch  => 'ruby-1.9'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
    gem 'capybara'
    gem 'cucumber-rails'
    gem 'database_cleaner'
    gem 'launchy'
    gem 'ruby-debug19', :require => 'ruby-debug'
end

group :deployment do
  gem 'thin'
end
