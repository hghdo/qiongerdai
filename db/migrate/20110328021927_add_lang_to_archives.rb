class AddLangToArchives < ActiveRecord::Migration
  def self.up
    add_column :archives,:lang,:string # zh_cn/zh_tw/zh_hk
  end

  def self.down
    remove_column :archives,:lang
  end
end
