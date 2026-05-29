class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { greater_than: 0 }

  def line_total_cents
    price_cents * quantity
  end
end
