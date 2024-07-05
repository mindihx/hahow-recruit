# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :chapters, allow_destroy: true

  validates :name, presence: true, length: { maximum: 200 }
  validates :teacher_name, presence: true, length: { maximum: 100 }
end
