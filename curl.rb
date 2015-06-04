#! /usr/bin/env ruby

require "faraday"
require "json"

conn = Faraday.new(:url => "https://www.tumblr.com") do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

response = conn.post do |req|
  req.url "/svc/search/inline_gif"
  req.headers["cookie"] = "pfp=ifMVfdKh5mrfxBApxKuxRbtz5QLe7GHieTUwgrMz; pfs=6UtIqP0FILNPClJ8eD5ggwmdV8; pfe=1441213499; pfu=120853812"
  req.body = 'q=&limit=200'
end

data = JSON.parse response.body

data["response"]["media"].each do |pic|
  puts pic["media_url"]
end
