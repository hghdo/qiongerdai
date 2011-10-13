class AddInstallDateStrToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :install_date_str, :string
  end

  def self.down
    remove_column :devices, :install_date_str
  end
end