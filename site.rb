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
      req.headers["cookie"] = "pfp=ifMVfdKh5mrfxBApxKuxRbtz5QLe7GHieTUwgrMz; pfs=6UtIqP0FILNPClJ8eD5ggwmdV8; pfe=1441213499; pfu=120853812"
      req.body = URI.encode_www_form({ q: str, limit: 100 })
    end

    data = JSON.parse response.body

    return data["response"]["media"].map do |pic|
      pic["media_url"]
    end.uniq.shuffle
  rescue => e
    logger.error e
    return Dir.foreach("#{settings.public_dir}/img/gifs").reject { |l| l[0] == "." }.map {|l| "/img/gifs/#{l}" }.shuffle
  end
end
