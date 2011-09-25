class CreateAdminReleases < ActiveRecord::Migration
  def self.up
    create_table :admin_releases do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_releases
  end
end
