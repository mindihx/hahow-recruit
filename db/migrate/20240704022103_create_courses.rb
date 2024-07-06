# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string "name", null: false
      t.string "teacher_name", null: false
      t.text "description"
      t.timestamps
    end
  end
end
