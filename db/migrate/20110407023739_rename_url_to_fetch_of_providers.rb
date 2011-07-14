class RenameUrlToFetchOfProviders < ActiveRecord::Migration
  def self.up
    rename_column :providers, :url_pattern_for_fetch_archive, :url_patterns_to_follow
  end

  def self.down
    rename_column :providers, :url_patterns_to_follow,:url_pattern_for_fetch_archive
  end
end
