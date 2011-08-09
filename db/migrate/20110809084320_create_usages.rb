# Each row represents two weeks data.
# Each hour is a column in table
class CreateHourPreferUsages < ActiveRecord::Migration
  def self.up
    create_table :hour_prefer_usages do |t|
      t.integer :one_am
      t.integer :two_am
      t.integer :three_am
      t.integer :four_am
      t.integer :five_am
      t.integer :six_am
      t.integer :seven_am
      t.integer :eight_am
      t.integer :nine_am
      t.integer :ten_am
      t.integer :eleven_am
      t.integer :twelve_am
      t.integer :one_pm
      t.integer :two_pm
      t.integer :three_pm
      t.integer :four_pm
      t.integer :five_pm
      t.integer :six_pm
      t.integer :seven_pm
      t.integer :eight_pm
      t.integer :nine_pm
      t.integer :ten_pm
      t.integer :eleven_pm
      t.integer :twelve_pm
      t.timestamps
    end
  end

  def self.down
    drop_table :hour_prefer_usages
  end
end
