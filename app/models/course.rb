# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :chapters, allow_destroy: true

  validates :name, presence: true, length: { maximum: 200 }
  validates :teacher_name, presence: true, length: { maximum: 100 }

  MAX_CHAPTERS_NUM = 100
  MAX_UNITS_NUM = 100

  # rubocop:disable Metrics/CyclomaticComplexity
  def check_chapters_and_units_num
    chapters_to_check = chapters.reject(&:_destroy)
    raise ArgumentError, "Chapters can't be empty" if chapters_to_check.empty?
    if chapters_to_check.size > MAX_CHAPTERS_NUM
      raise ArgumentError, "Number of chapters is at most #{MAX_CHAPTERS_NUM}"
    end

    chapters_to_check.each do |chapter|
      units_to_check = chapter.units.reject(&:_destroy)
      raise ArgumentError, "Chapters units can't be empty" if units_to_check.empty?
      raise ArgumentError, "Number of chapters units is at most #{MAX_UNITS_NUM}" if units_to_check.size > MAX_UNITS_NUM
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
