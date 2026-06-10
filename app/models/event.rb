class Event < ApplicationRecord
  NAMES = %w[login registration content_view add_to_cart].freeze

  belongs_to :user, optional: true
  belongs_to :subject, polymorphic: true, optional: true

  validates :name, :occurred_at, presence: true
  validates :name, inclusion: { in: NAMES }
  validates :properties, presence: true
end
