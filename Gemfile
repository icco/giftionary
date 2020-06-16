source "https://rubygems.org"

ruby "2.5.0"

gem "activerecord", "~> 5.0", require: "active_record"
gem "erubis"
gem "fog-google", git: "https://github.com/fog/fog-google.git", branch: "upgrade-google-client"
gem "mime-types"
gem "mini_magick", ">= 4.9.4"
gem "omniauth", ">= 1.8.1"
gem "omniauth-twitter", ">= 1.4.0"
gem "pg"
gem "rack-protection", ">= 2.0.0", require: "rack/protection"
gem "rack-ssl-enforcer"
gem "rake"
gem "secure_headers", "~> 3.0" # TODO: Upgrade to 4.0
gem "sinatra", ">= 2.0.0", require: "sinatra/base"
gem "sinatra-activerecord", ">= 2.0.13", require: "sinatra/activerecord"
gem "textacular"
gem "thin", ">= 1.7.2"
gem "typhoeus"

group :test do
  gem "rack-test", ">= 0.8.2"
  gem "vcr"
end

# For dev
group :development do
  gem "rubocop"
  gem "shotgun", ">= 0.9.2"
  gem "travis"
end
