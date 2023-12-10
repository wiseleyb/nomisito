# frozen_string_literal: true

class CreateIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :ingredients do |t|
      t.string :name, index: true
      t.string :site_klass, index: true
      t.string :edamam_food_id
      t.string :edamam_img
      t.string :edamam_measure_uri
      t.jsonb  :edamam_nutrition
      t.timestamps
    end
  end
end
