class AccountController < ApplicationController
  def show
    @recent_product_views = current_user.product_views.includes(:product).order(viewed_at: :desc).limit(4)
  end
end
