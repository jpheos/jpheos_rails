class CreatePushbulletTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :pushbullet_tokens do |t|
      t.references :user, foreign_key: true
      t.string :access_token
      t.text :device

      t.timestamps
    end
  end
end
