require "rubygems"
require "bundler"
RACK_ENV = (ENV["RACK_ENV"] || :development).to_sym
Bundler.require(:default, RACK_ENV)

require "logger"
require "set"

ActiveRecord::Base.extend(Textacular)

require "./version.rb"
require "./lib/image.rb"

class Giftionary < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  use Rack::Deflater

  layout :main
  configure do
    set :logging, true

    connections = {
      development: "postgres://localhost/giftionary",
      test: "postgres://postgres@localhost/giftionary_test",
      production: ENV["DATABASE_URL"],
    }

    url = URI(connections[RACK_ENV])
    options = {
      adapter: url.scheme,
      host: url.host,
      port: url.port,
      database: url.path[1..-1],
      username: url.user,
      password: url.password,
    }

    case url.scheme
    when "sqlite"
      options[:adapter] = "sqlite3"
      options[:database] = url.host + url.path
    when "postgres"
      options[:adapter] = "postgresql"
    end
    set :database, options

    use Rack::Session::Cookie, key: "rack.session",
                               path: "/",
                               expire_after: 86_400, # 1 day
                               secret: ENV["SESSION_SECRET"]
    use OmniAuth::Builder do
      provider :twitter, ENV["TWITTER_CONSUMER_KEY"], ENV["TWITTER_CONSUMER_SECRET"]
    end

    MiniMagick.configure do |config|
      config.timeout = 1
    end
  end

  before do
    if session[:username]
      @connection = Fog::Storage::GoogleJSON.new(google_project: "icco-natwelch",
                                                 google_json_key_string: ENV["GOOGLE_JSON_KEY"])
      @bucket = @connection.directories.get("giftionary")
      @files = Fog::Storage::GoogleJSON::Files.new(directory: @bucket,
                                                   service: @connection,
                                                   preifx: "#{session[:username]}/")
    end
  end

  get "/health/?" do
    "ok"
  end

  get "/" do
    if session[:username]
      redirect "/#{session[:username]}"
    else
      erb :login
    end
  end

  get "/auth/:name/callback" do
    auth = request.env["omniauth.auth"]
    session[:username] = auth.info.nickname

    redirect "/"
  end

  get "/logout" do
    session[:username] = nil
    session = nil

    redirect "/"
  end

  post "/upload" do
    unless session[:username]
      error 403
      return
    end

    uuid = SecureRandom.uuid
    filename = "#{session[:username]}/#{uuid}"
    tmpfile = params["file"][:tempfile]

    # We only support images
    unless file_is_image?(tmpfile)
      error 400
      return
    end

    tmpfile.rewind

    file = @bucket.files.create(
      key: filename,
      body: File.open(tmpfile),
      public: true
    )

    i = Image.new
    i.username = session[:username]
    i.stub = params["stub"].to_s.downcase
    i.description = params["description"]
    i.url = file.public_url
    i.save

    redirect "/"
  end

  get "/:username/:stub" do
    @image = Image.where(username: params[:username], stub: params[:stub]).first
    redirect @image.url
  end

  get "/:username" do
    @title = "@#{params["username"]}"
    if session[:username] && session[:username] == params["username"]
      @images = Image.where(username: session[:username]).order(updated_at: :desc)
      erb :home
    else
      redirect "/"
    end
  end

  def title
    if @title
      " - #{@title}"
    else
      ""
    end
  end

  def file_is_image? file
    image = MiniMagick::Image.read(file)
    return image.valid?
  end
end
