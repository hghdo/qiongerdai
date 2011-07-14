class AddScanRegexpForPubDateToProvider < ActiveRecord::Migration
  def self.up
    add_column :providers, :regex_for_scan_pub_date,:string
  end

  def self.down
    remove_column :providers, :regex_for_scan_pub_date
  end
end
