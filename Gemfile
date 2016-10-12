source "https://rubygems.org"

ruby "2.3.1"

gem "activerecord", "~> 4.2", require: "active_record"
gem "activesupport", "~> 4.2", require: ["active_support", "active_support/core_ext"]
gem "erubis"
gem "fog-google"
gem "json"
gem "mime-types"
gem "oj"
gem "oj_mimic_json"
gem "omniauth"
gem "google-api-client", '~> 0.8.6'
gem "omniauth-twitter"
gem "pg"
gem "rack-protection", require: "rack/protection"
gem "rake"
gem "sinatra", require: "sinatra/base"
gem "sinatra-activerecord", require: "sinatra/activerecord"
gem "sinatra-contrib", require: ["sinatra/json"]
gem "thin"

group :test do
  gem "rack-test"
  gem "vcr"
end

# For dev
group :development do
  gem "rubocop"
  gem "shotgun"
  gem "travis"
end
