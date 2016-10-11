require File.expand_path '../test_helper.rb', __FILE__

class Test < Minitest::Test
  include Rack::Test::Methods

  def app
    Giftionary
  end

  def test_health_no_slash
    get '/health'
    assert last_response.ok?
  end

  def test_health_slash
    get '/health/'
    assert last_response.ok?
  end
end
