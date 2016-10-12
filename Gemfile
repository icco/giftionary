source "https://rubygems.org"

ruby "2.3.1"

gem "activerecord", "~> 4.2", require: "active_record"
gem "erubis"
gem "fog-google"
gem "mime-types"
gem "omniauth"
gem "google-api-client", "~> 0.8.6"
gem "omniauth-twitter"
gem "pg"
gem "rack-protection", require: "rack/protection"
gem "rake"
gem "sinatra", require: "sinatra/base"
gem "sinatra-activerecord", require: "sinatra/activerecord"
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
