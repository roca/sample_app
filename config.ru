require 'rubygems'
require 'bundler'
Bundler.setup
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run SampleApp31::Application
