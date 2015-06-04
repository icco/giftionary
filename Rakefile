require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

desc "Run a local server."
task :local do
  Kernel.exec("shotgun -s thin -p 9393")
end
