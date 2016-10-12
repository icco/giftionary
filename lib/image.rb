class Image < ActiveRecord::Base
  def share
    "/#{username}/#{stub}"
  end
end
