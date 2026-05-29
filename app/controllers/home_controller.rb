class HomeController < ApplicationController
  def index
    @featured_products = Product.featured.limit(3)
  end
end
