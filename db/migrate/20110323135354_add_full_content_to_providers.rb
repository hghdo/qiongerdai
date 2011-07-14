class AddFullContentToProviders < ActiveRecord::Migration
  def self.up
    add_column :providers, :full_content, :boolean,:default => false
  end

  def self.down
    remove_column :providers, :full_content
  end
end
