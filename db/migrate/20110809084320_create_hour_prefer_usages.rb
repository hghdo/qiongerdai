# Each row represents two weeks data.
# Each hour is a column in table
class CreateHourPreferUsages < ActiveRecord::Migration
  def self.up
    create_table :hour_prefer_usages do |t|
      t.integer :one_am, :default => 0
      t.integer :two_am, :default => 0
      t.integer :three_am, :default => 0
      t.integer :four_am, :default => 0
      t.integer :five_am, :default => 0
      t.integer :six_am, :default => 0
      t.integer :seven_am, :default => 0
      t.integer :eight_am, :default => 0
      t.integer :nine_am, :default => 0
      t.integer :ten_am, :default => 0
      t.integer :eleven_am, :default => 0
      t.integer :twelve_am, :default => 0
      t.integer :one_pm, :default => 0
      t.integer :two_pm, :default => 0
      t.integer :three_pm, :default => 0
      t.integer :four_pm, :default => 0
      t.integer :five_pm, :default => 0
      t.integer :six_pm, :default => 0
      t.integer :seven_pm, :default => 0
      t.integer :eight_pm, :default => 0
      t.integer :nine_pm, :default => 0
      t.integer :ten_pm, :default => 0
      t.integer :eleven_pm, :default => 0
      t.integer :twelve_pm, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :hour_prefer_usages
  end
end
