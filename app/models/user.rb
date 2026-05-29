class User < ApplicationRecord
  before_validation :assign_uuid, on: :create

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :product_views, dependent: :destroy
  has_many :viewed_products, through: :product_views, source: :product
  has_many :cart_items, dependent: :destroy
  has_many :cart_products, through: :cart_items, source: :product
  has_many :orders, dependent: :destroy

  validates :name, :email_address, :customer_tier, :skin_type, :uuid, presence: true
  validates :email_address, uniqueness: true
  validates :uuid, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def member_id
    "shop_user_#{uuid}"
  end

  def cart_items_count
    cart_items.sum(:quantity)
  end

  def cart_total_cents
    cart_items.includes(:product).sum { |item| item.line_total_cents }
  end

  private

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
