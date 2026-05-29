class Product < ApplicationRecord
  validates :name, :slug, :category, :description, :price_cents, :image_url, :skin_type, presence: true
  validates :slug, uniqueness: true
  validates :price_cents, numericality: { greater_than: 0 }

  scope :featured, -> { where(featured: true) }

  def to_param
    slug
  end
end
