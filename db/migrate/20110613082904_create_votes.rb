class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.string :klass
      t.references :user
      t.integer :target_id

      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
