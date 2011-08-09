class CreateDevices < ActiveRecord::Migration
  # Usage code generated in client:
  # 20202340506010200010201
  # Each digital represent usage amount in one day
  def self.up
    create_table :devices do |t|
      t.string :imei_hash
      t.boolean :debug, :default => false 
      t.string :version
      t.string :os
      t.string :os_version
      t.string :device_vendor
      t.string :device_name
      t.string :operator
      t.string :first_installation_channel
      t.string :last_installation_channel
      t.integer :totally_usage, :default => 0 
      t.float :average_using_frequency, :default => 0
      t.float :recent_using_frequency, :default => 0
      t.string :recent_usage
      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
