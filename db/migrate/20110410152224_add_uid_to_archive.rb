class AddUidToArchive < ActiveRecord::Migration
  def self.up
    add_column :archives, :uid, :string
  end

  def self.down
    remove_column :archives, :uid
  end
end
