class CreateClientApps < ActiveRecord::Migration
  def self.up
    create_table :client_apps do |t|
      t.string :pkg_name
      t.string :version_name
      t.integer :build
      t.string :platform
      t.string :app    

      t.timestamps
    end
  end

  def self.down
    drop_table :client_apps
  end
end
