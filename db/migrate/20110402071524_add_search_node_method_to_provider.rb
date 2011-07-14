class AddSearchNodeMethodToProvider < ActiveRecord::Migration
  def self.up
    add_column :providers, :search_node_method , :string, :default => 'xpath'
  end

  def self.down
    remove_column :providers, :search_node_method
  end
end
