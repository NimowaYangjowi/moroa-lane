class ProductView < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :viewed_at, presence: true
end
