class AddUidToArchive < ActiveRecord::Migration
  def self.up
    add_column :archives, :uid, :string
    add_column :providers, :uid_pattern,:string
  end

  def self.down
    remove_column :archives, :uid
    remove_column :providers, :uid_pattern
  end
end
