class ProductsController < ApplicationController
  def index
    @products = Product.order(:category, :name)
  end

  def show
    @product = Product.find_by!(slug: params[:id])
    remember_recent_product(@product)
    @recent_products = Product.where(slug: session[:recent_product_slugs]).where.not(id: @product.id)
  end

  private

  def remember_recent_product(product)
    slugs = Array(session[:recent_product_slugs])
    session[:recent_product_slugs] = ([ product.slug ] + slugs).uniq.first(4)
  end
end
