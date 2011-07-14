class AddFetchConditionsOfBbsToProvider < ActiveRecord::Migration
  def self.up
    remove_column :providers, :forum
    add_column :providers, :min_hit, :integer, :default => 50
    add_column :providers, :max_age, :integer, :default => 3
  end

  def self.down
    add_column :providers, :forum,:boolean,:default => false
    remove_column :providers, :min_hit
    remove_column :providers, :max_age
  end
end
