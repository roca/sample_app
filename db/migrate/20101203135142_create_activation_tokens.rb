class CreateActivationTokens < ActiveRecord::Migration
  def self.up
    create_table :activation_tokens do |t|
      t.string :token
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :activation_tokens
  end
end
