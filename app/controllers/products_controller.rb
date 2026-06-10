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
    @cart_item = current_user&.cart_items&.find_by(product: @product)
  end

  private

  def remember_recent_product(product)
    slugs = Array(session[:recent_product_slugs])
    session[:recent_product_slugs] = ([ product.slug ] + slugs).uniq.first(4)
  end

  def record_product_view(product)
    record_event(
      "content_view",
      subject: product,
      properties: {
        product_id: product.id,
        product_slug: product.slug,
        product_name: product.name
      }
    )

    return unless current_user

    current_user.product_views.create!(product:, viewed_at: Time.current)
  end
end
