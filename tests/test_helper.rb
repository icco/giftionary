ENV["RACK_ENV"] = "test"
require "minitest/autorun"
require "rack/test"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "tests/vcr_cassettes"
  config.hook_into :excon
  config.default_cassette_options = {
    record: :new_episodes,
    allow_playback_repeats: true,
  }
end

require File.expand_path "../../site.rb", __FILE__
