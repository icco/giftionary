require "rubygems"
require "bundler"
RACK_ENV = (ENV['RACK_ENV'] || :development).to_sym
Bundler.require(:default, RACK_ENV)

require "logger"
require "set"

require './version.rb'
require './lib/image.rb'

class Giftionary < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  use Rack::Deflater

  layout :main
  configure do
    set :logging, true

    connections = {
      :development => "postgres://localhost/giftionary",
      :test => "postgres://postgres@localhost/giftionary_test",
      :production => ENV['DATABASE_URL']
    }

    url = URI(connections[RACK_ENV])
    options = {
      :adapter => url.scheme,
      :host => url.host,
      :port => url.port,
      :database => url.path[1..-1],
      :username => url.user,
      :password => url.password
    }

    case url.scheme
    when "sqlite"
      options[:adapter] = "sqlite3"
      options[:database] = url.host + url.path
    when "postgres"
      options[:adapter] = "postgresql"
    end
    set :database, options

    use Rack::Session::Cookie, :key => 'rack.session',
      :path => '/',
      :expire_after => 86400, # 1 day
      :secret => ENV['SESSION_SECRET']
    use OmniAuth::Builder do
      provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
    end

  end

  get "/health/?" do
    "ok"
  end

  get "/" do
    if session[:username]
      erb :home
    else
      erb :login
    end
  end

  get '/auth/:name/callback' do
    auth = request.env['omniauth.auth']
    session[:username] = auth.info.nickname

    redirect '/'
  end
end
