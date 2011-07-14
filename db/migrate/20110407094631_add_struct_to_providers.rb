class AddStructToProviders < ActiveRecord::Migration
  def self.up
    add_column :providers, :struct, :string
  end

  def self.down
    remove_column :providers, :struct
  end
end
