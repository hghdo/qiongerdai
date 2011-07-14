class IntegrateStatusToArchives < ActiveRecord::Migration
  def self.up
    add_column :archives, :status, :integer, :default => 0
    remove_column :archives, :analyzed
    remove_column :archives, :synchronized
    remove_column :archives, :ok
    remove_column :archives, :locked
    remove_column :archives, :deleted
  end

  def self.down
    add_column :archives, :analyzed, :boolean
    add_column :archives, :synchronized, :boolean
    add_column :archives, :ok, :boolean
    add_column :archives, :locked, :boolean
    add_column :archives, :deleted, :boolean
  end
end
