require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

require "rake/testtask"
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./site"
  end
end

Rake::TestTask.new do |t|
  t.pattern = "tests/*_test.rb"
end

task default: [:environment, :test]
task environment: ["db:load_config"]

desc "Run a local server."
task :local do
  Kernel.exec("shotgun -s thin -p 9393")
end
