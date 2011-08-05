class AddUidToArchive < ActiveRecord::Migration
  def self.up
    add_column :archives, :uid, :string
    add_index  :archives, [:uid], :unique => true
  end

  def self.down
    remove_column :archives, :uid
  end
end
