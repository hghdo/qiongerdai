class CreateProviders < ActiveRecord::Migration
  def self.up
    create_table :providers do |t|
      t.string :title
      t.string :url
      t.string :description
      t.references :category
      t.string :encoding
      t.text   :url_pattern_for_fetch_archive
      t.string :url_pattern_for_archive
      t.string :url_pattern_for_skip
      t.string :content_xpath
      t.string :format #html,RSS1, RSS2, ATOM
      t.integer :max_crawl_depth,:default => 3
      t.boolean :enabled, :default => false
      t.datetime :fetched_at
      t.integer :frequence
      t.integer :rank

      t.timestamps
    end
  end

  def self.down
    drop_table :providers
  end
end
