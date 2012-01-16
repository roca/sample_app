source 'http://rubygems.org'

gem "heroku"

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'



group :production do
  gem 'pg'
end
group :development, :test do
  gem 'mysql'
end

gem 'gravatar_image_tag','1.0.0'
gem 'kaminari'
gem 'haml'



# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'faker','0.3.1'
gem 'jquery-rails'

group :development do 
	gem 'rspec-rails', '2.6.1'
	gem 'annotate-models','1.0.4', :path => '/Users/roca/.rvm/gems/ruby-1.9.2-p0@rails3/gems/annotate-models-1.0.4'

end
group :test do 
  gem 'rspec-rails', '2.6.1'
  gem 'capybara'
	gem 'spork', '0.9.0.rc9'
	gem 'factory_girl_rails','1.0'
	gem 'rb-fsevent'
	gem 'growl'
	gem 'ruby_gntp'
  gem 'growl_notify', '0.0.3'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'guard-spork'
  
end
# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'execjs'
gem "therubyracer", :require => 'v8'
gem "js-routes"
