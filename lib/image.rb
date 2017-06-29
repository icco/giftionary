class Image < ActiveRecord::Base
  validates :stub, format: { with: /\A[a-z\-\_0-9]+\z/, message: "only allows letters, numbers, dashes and underbars" }

  def share
    "/#{username}/#{stub}"
  end
end
