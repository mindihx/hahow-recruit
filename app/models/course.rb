# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :chapters, allow_destroy: true

  validates :name, presence: true, length: { maximum: 200 }
  validates :teacher_name, presence: true, length: { maximum: 100 }

  MAX_CHAPTERS_NUM = 100
  MAX_UNITS_NUM = 100

  def check_chapters_and_units_num
    raise ArgumentError, "Chapters can't be empty" if chapters.empty?
    raise ArgumentError, "Number of chapters is at most #{MAX_CHAPTERS_NUM}" if chapters.size > MAX_CHAPTERS_NUM

    chapters.each do |chapter|
      raise ArgumentError, "Chapters units can't be empty" if chapter.units.empty?
      raise ArgumentError, "Number of chapters units is at most #{MAX_UNITS_NUM}" if chapter.units.size > MAX_UNITS_NUM
    end
  end
end
