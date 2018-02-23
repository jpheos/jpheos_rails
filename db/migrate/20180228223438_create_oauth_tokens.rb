class CreateOauthTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :oauth_tokens do |t|
      t.references :user, foreign_key: true
      t.string :token
      t.string :refresh_token
      t.integer :expires_at

      t.timestamps
    end
  end
end
