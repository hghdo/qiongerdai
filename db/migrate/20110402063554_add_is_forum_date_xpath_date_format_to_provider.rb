class AddIsForumDateXpathDateFormatToProvider < ActiveRecord::Migration
  def self.up
    add_column :providers, :forum,:boolean,:default => false
    add_column :providers, :pub_date_xpath,:string
    add_column :providers, :date_format,:string
  end

  def self.down
    remove_column :providers, :forum
    remove_column :providers, :pub_date_xpath
    remove_column :providers, :date_format
  end
end
