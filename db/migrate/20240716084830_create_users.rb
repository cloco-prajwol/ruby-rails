class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.string :phone
      t.datetime :dob
      t.string :gender
      t.string :address
      t.timestamps
    end
  end
end
