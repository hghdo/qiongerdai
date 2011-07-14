class CreateThings < ActiveRecord::Migration
  def self.up
    create_table :things do |t|
      t.string :title
      t.string :alias
      t.references :category

      t.timestamps
    end
  end

  def self.down
    drop_table :things
  end
end
