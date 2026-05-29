class Product < ApplicationRecord
  has_many :product_views, dependent: :destroy
  has_many :viewers, through: :product_views, source: :user
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_exception

  validates :name, :slug, :category, :description, :price_cents, :image_url, :skin_type, presence: true
  validates :slug, uniqueness: true
  validates :price_cents, numericality: { greater_than: 0 }

  scope :featured, -> { where(featured: true) }

  def to_param
    slug
  end
end
