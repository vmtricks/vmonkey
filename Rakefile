require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

ENV['VMONKEY_YML'] ||= File.expand_path(File.join(File.dirname(__FILE__), 'spec', '.vmonkey'))
RSpec::Core::RakeTask.new(:spec)