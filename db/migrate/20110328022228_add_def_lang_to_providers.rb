class AddDefLangToProviders < ActiveRecord::Migration
  def self.up
    add_column :providers,:def_lang,:string
  end

  def self.down
    remove_column :providers,:def_lang
  end
end
