# frozen_string_literal: true

class CreateIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :ingredients do |t|
      t.string :name, index: true
      t.string :site_klass, index: true
      t.jsonb  :edamam_results, default: {}
      t.timestamps
    end
  end
end
