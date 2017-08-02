require "rubygems"
require "bundler"
RACK_ENV = (ENV["RACK_ENV"] || :development).to_sym
Bundler.require(:default, RACK_ENV)

require "logger"

ActiveRecord::Base.extend(Textacular)

require "./version.rb"
require "./lib/image.rb"

class Giftionary < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  use Rack::Deflater
  use SecureHeaders::Middleware

  if RACK_ENV.eql? :production
    # Force HTTPS
    use Rack::SslEnforcer
  end

  layout :main
  configure do
    set :logging, true

    connections = {
      development: "postgres://localhost/giftionary",
      test: "postgres://postgres@localhost/giftionary_test",
      production: ENV["DATABASE_URL"],
    }
    # connections[:development] = ENV["DATABASE_URL"]

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

    # rubocop:disable all
    SecureHeaders::Configuration.default do |config|
      # We just want the defaults.
      config.csp = SecureHeaders::OPT_OUT
      config.csp_report_only = {
        # "meta" values. these will shaped the header, but the values are not included in the header.
        preserve_schemes: true, # default: false. Schemes are removed from host sources to save bytes and discourage mixed content.

        # directive values: these values will directly translate into source directives
        default_src: %w(https: 'self'),
        base_uri: %w('self'),
        block_all_mixed_content: true, # see http://www.w3.org/TR/mixed-content/
        child_src: %w('self'), # if child-src isn't supported, the value for frame-src will be set.
        connect_src: %w(wss:),
        font_src: %w('self' data:),
        form_action: %w('self'),
        frame_ancestors: %w('none'),
        script_src: %w('self'),
        style_src: %w('unsafe-inline' unpkg.com),
        report_uri: %w(https://191252c4ba611a6b85d3420e1825bcb5.report-uri.io/r/default/csp/reportOnly),
      }
    end
    # rubocop:enable all
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

    puts "User-Agent: #{request.user_agent}"
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

  get "/about/?" do
    erb :about
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

  get "/search/*" do
    unless session[:username]
      error 403
      return
    end

    @search = params["splat"].join(" ")
    @images = Image.where(username: session[:username]).basic_search(@search)
    erb :search
  end

  post "/search/?" do
    redirect "/search/#{params["search"]}"
  end

  post "/upload" do
    unless session[:username]
      error 403
      return
    end

    uuid = SecureRandom.uuid
    filename = "#{session[:username]}/#{uuid}"
    tmpfile = params["file"][:tempfile]
    mimetype = get_mime_type(tmpfile)

    # We only support images
    if mimetype.nil?
      error 400
      return
    end

    tmpfile.rewind
    fp = File.open(tmpfile)
    file = @bucket.files.create(
      key: filename,
      body: fp,
      public: true,
      contentType: mimetype
    )
    fp.close

    i = Image.new
    i.username = session[:username]
    i.stub = params["stub"].to_s.downcase
    i.description = params["description"]
    i.url = file.public_url
    i.mimetype = mimetype
    i.save

    error 400 unless i.valid?

    redirect "/"
  end

  get "/:username/:stub" do
    @image = Image.where(username: params[:username], stub: params[:stub]).first
    error 404 unless @image

    if /^Twitterbot/.match(request.user_agent)
      erb :twitter, layout: false
    else
      Typhoeus::Config.user_agent = "Giftionary/#{VERSION} (+https://github.com/icco/giftionary)"
      # TODO: Replace with imgix_url
      resp = Typhoeus.get(@image.url, followlocation: true)

      headers resp.headers
      resp.body
    end
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

  def get_mime_type(file)
    image = MiniMagick::Image.read(file)
    return image.mime_type if image.valid?

    nil
  end
end
