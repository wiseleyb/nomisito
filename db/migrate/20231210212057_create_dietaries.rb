class CreateDietaries < ActiveRecord::Migration[7.0]
  def change
    create_table :dietaries do |t|
      t.string :name, index: true
      t.string :site_klass, index: true

      t.timestamps
    end
  end
end
