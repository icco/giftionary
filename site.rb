require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

configure do
  RACK_ENV = (ENV["RACK_ENV"] || :development).to_sym
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

def get_gifs(str)
  # Setup connection options for talking to Tumblr
  conn = Faraday.new(url: "https://www.tumblr.com") do |faraday|
    faraday.request :url_encoded
    faraday.response :logger
    faraday.adapter Faraday.default_adapter
  end

  # Actually make the request
  response = conn.post do |req|
    req.url "/svc/search/inline_gif"
    req.headers["cookie"] = "pfp=5zg5qruuAbA17VdlWvj0iDRTF7pj8zS9FNVDbOFm; pfs=HZdC210qeABdV7Y4oBU0QRP5w3Q; pfe=1453524233; pfu=120853812;"
    req.headers["x-tumblr-form-key"] = "TZDa1ozE8d8ebfft06sPZakAypM"
    req.headers["cache-control"] = "no-cache"
    req.body = URI.encode_www_form(q: str, limit: 200)
  end

  data = JSON.parse response.body

  if data["meta"]["status"] != 200
    fail "ERROR: #{data["meta"]["msg"]}. #{data["response"]}"
  end

  return data["response"]["media"].map do |pic|
    pic["media_url"]
  end.uniq.shuffle
rescue => e
  logger.error e
  logger.error data["response"] if data
  if RACK_ENV == :development
    files = Dir.foreach("#{settings.public_dir}/img/gifs").reject { |l| l[0] == "." }
    return files.map { |l| "/img/gifs/#{l}" }.shuffle
  else
    return []
  end
end
