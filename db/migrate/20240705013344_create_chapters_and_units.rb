# frozen_string_literal: true

class CreateChaptersAndUnits < ActiveRecord::Migration[7.1]
  def change
    create_table :chapters do |t|
      t.references :course, foreign_key: true, null: false
      t.string :name, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end

    create_table :units do |t|
      t.references :chapter, foreign_key: true, null: false
      t.string :name, null: false
      t.text :description
      t.text :content, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end
  end
end
