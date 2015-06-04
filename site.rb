require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

configure do
  RACK_ENV = (ENV['RACK_ENV'] || :development).to_sym
end

get "/" do
  @urls = []
  erb :index
end

post "/" do
  redirect "/s/#{params["q"]}"
end

get "/s/:query" do
  @query = params[:query]
  @urls = get_gifs @query

  erb :index
end

def get_gifs str
  conn = Faraday.new(:url => "https://www.tumblr.com") do |faraday|
    faraday.request  :url_encoded
    faraday.response :logger
    faraday.adapter  Faraday.default_adapter
  end
  response = conn.post do |req|
    req.url "/svc/search/inline_gif"
    req.headers["cookie"] = "pfp=ifMVfdKh5mrfxBApxKuxRbtz5QLe7GHieTUwgrMz; pfs=6UtIqP0FILNPClJ8eD5ggwmdV8; pfe=1441213499; pfu=120853812"
    req.body = URI.encode_www_form({ q: str, limit: 200 })
  end

  data = JSON.parse response.body

  return data["response"]["media"].map do |pic|
    pic["media_url"]
  end
end
