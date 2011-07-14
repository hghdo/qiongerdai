class RenameUrlPatternForArchiveToArchiveUrlPatterns < ActiveRecord::Migration
  def self.up
    rename_column :providers ,:url_pattern_for_archive,:archive_url_patterns
    rename_column :providers, :url_pattern_for_skip,:url_patterns_to_skip
  end

  def self.down
    rename_column :providers ,:archive_url_patterns ,:url_pattern_for_archive
    rename_column :providers ,:url_patterns_to_skip,:url_pattern_for_skip
  end
end
