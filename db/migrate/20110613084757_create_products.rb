class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.references :brand
      t.references :thing
      t.string :name
      t.string :subname
      t.text :desc

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
