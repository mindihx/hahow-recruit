# frozen_string_literal: true

class Chapter < ApplicationRecord
  belongs_to :course
  has_many :units, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :units, allow_destroy: true

  validates :name, presence: true, length: { maximum: 200 }
  validates :position, numericality: { greater_than_or_equal_to: 0 }
end
