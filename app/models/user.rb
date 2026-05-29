class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :product_views, dependent: :destroy
  has_many :viewed_products, through: :product_views, source: :product

  validates :name, :email_address, :customer_tier, :skin_type, presence: true
  validates :email_address, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def member_id
    "user_#{id}"
  end
end
