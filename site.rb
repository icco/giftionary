require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

configure do
  RACK_ENV = (ENV['RACK_ENV'] || :development).to_sym
  enable :logging
end

get "/" do
  @urls = []
  erb :index
end

post "/" do
  redirect "/s/#{params["q"]}"
end

get "/s/" do
  redirect "/"
end

get %r{/s/([A-z0-9\-\_ (%20)]+)\.json} do
  @query = params["captures"][0]
  @urls = get_gifs @query

  content_type :json
  @urls.to_json
end

get %r{/s/([A-z0-9\-\_ (%20)]+)} do
  @query = params["captures"][0]
  @urls = []

  erb :index
end

not_found do
  erb "404".to_sym
end

def get_gifs str
  begin
    # Setup connection options for talking to Tumblr
    conn = Faraday.new(:url => "https://www.tumblr.com") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    # Actually make the request
    response = conn.post do |req|
      req.url "/svc/search/inline_gif"
      req.headers["Cookie"] = "pfp=gODtDkLrHgUTkhDmdGDlyWZ0eVGMr4aheNJqrtQB; pfs=cAb1Zkgms7RPrw2QbYud0tqm0; pfe=1448636043; pfu=120853812;"
      req.headers["X-tumblr-form-key"] = "TZDa1ozE8d8ebfft06sPZakAypM"
      req.body = URI.encode_www_form({ q: str, limit: 100 })
    end

    data = JSON.parse response.body

    if data["meta"]["status"] != 200
      raise "ERROR: #{data["meta"]["msg"]}. #{data["response"]}"
    end

    return data["response"]["media"].map do |pic|
      pic["media_url"]
    end.uniq.shuffle
  rescue => e
    logger.error e
    if data
      logger.error data["response"]
    end
    if RACK_ENV == :development
      return Dir.foreach("#{settings.public_dir}/img/gifs").reject { |l| l[0] == "." }.map {|l| "/img/gifs/#{l}" }.shuffle
    else
      return []
    end
  end
end
