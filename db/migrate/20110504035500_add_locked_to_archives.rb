class AddLockedToArchives < ActiveRecord::Migration
  def self.up
    add_column :archives, :locked, :boolean, :default => false
  end

  def self.down
    remove_column :archives, :locked
  end
end
