class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.references :user, foreign_key: true
      t.string :google_id
      t.string :name
      t.date :birthday
      t.string :phone
      t.string :email
      t.binary :photo64
      t.timestamps
    end
    add_index :contacts, :google_id
  end
end
