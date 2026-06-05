class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @featured_products = Product.featured.limit(3)
  end

  def channel_talk_guide
  end
end
