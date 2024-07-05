# frozen_string_literal: true

class Unit < ApplicationRecord
  belongs_to :chapter

  validates :name, presence: true, length: { maximum: 200 }
  validates :content, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }
end
