class Image < ActiveRecord::Base
  validates :stub, format: { with: /\A[a-z\-\_]+\z/, message: "only allows letters, dashes and underbars" }
  def share
    "/#{username}/#{stub}"
  end
end
