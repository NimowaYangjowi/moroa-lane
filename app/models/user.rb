class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :product_views, dependent: :destroy
  has_many :viewed_products, through: :product_views, source: :product
  has_many :cart_items, dependent: :destroy
  has_many :cart_products, through: :cart_items, source: :product
  has_many :orders, dependent: :destroy

  validates :name, :email_address, :customer_tier, :skin_type, presence: true
  validates :email_address, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def member_id
    "user_#{id}"
  end

  def cart_items_count
    cart_items.sum(:quantity)
  end

  def cart_total_cents
    cart_items.includes(:product).sum { |item| item.line_total_cents }
  end
end
