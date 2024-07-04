# frozen_string_literal: true

class Course < ApplicationRecord
  validates :name, :teacher_name, presence: true
end
