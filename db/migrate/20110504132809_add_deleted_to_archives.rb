class AddDeletedToArchives < ActiveRecord::Migration
  def self.up
    add_column :archives, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :archives, :deleted
  end
end
