class Image < ActiveRecord::Base
  validates :stub, format: { with: /\A[a-z\-\_0-9]+\z/, message: "only allows letters, numbers, dashes and underbars" }

  def share
    "/#{username}/#{stub}"
  end

  def imgix_url
    u = URI.parse(url)
    items = u.path.split("/")
    items.slice! 1 if items.size == 4

    "https://giftionary.imgix.net#{items.join("/")}?auto=compress,format"
  end
end
