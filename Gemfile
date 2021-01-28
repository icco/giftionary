source "https://rubygems.org"

ruby "2.5.0"

gem "activerecord", "~> 5.0", require: "active_record"
gem "erubis"
gem "fog-google", git: "https://github.com/fog/fog-google.git", branch: "upgrade-google-client"
gem "mime-types"
gem "mini_magick", ">= 4.9.4"
gem "omniauth"
gem "omniauth-twitter", ">= 1.4.0"
gem "pg"
gem "rack-protection", require: "rack/protection"
gem "rack-ssl-enforcer"
gem "rake"
gem "secure_headers", "~> 3.0" # TODO: Upgrade to 4.0
gem "sinatra", require: "sinatra/base"
gem "sinatra-activerecord", require: "sinatra/activerecord"
gem "textacular"
gem "thin"
gem "typhoeus"

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
