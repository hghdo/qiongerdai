class CreateArchives < ActiveRecord::Migration
  def self.up
    create_table :archives do |t|
      t.string :title
      t.text :desc
      t.text :content
      t.string :thumbnail
      t.string :url
      t.string :keywords
      t.datetime :pub_date
      t.boolean :analyzed,:default => false
      t.boolean :ok,:default => false
      t.boolean :synchronized,:default => false
      t.string  :cat
      t.references :provider

      t.timestamps
    end
  end

  def self.down
    drop_table :archives
  end
end
