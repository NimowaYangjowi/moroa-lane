class ProductsController < ApplicationController
  allow_unauthenticated_access

  def index
    @products = Product.order(:category, :name)
  end

  def show
    @product = Product.find_by!(slug: params[:id])
    remember_recent_product(@product)
    record_product_view(@product)
    @recent_products = Product.where(slug: session[:recent_product_slugs]).where.not(id: @product.id)
  end

  private

  def remember_recent_product(product)
    slugs = Array(session[:recent_product_slugs])
    session[:recent_product_slugs] = ([ product.slug ] + slugs).uniq.first(4)
  end

  def record_product_view(product)
    return unless current_user

    current_user.product_views.create!(product:, viewed_at: Time.current)
  end
end
