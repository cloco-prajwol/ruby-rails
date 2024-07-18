class CreateMusics < ActiveRecord::Migration[7.1]
  def change
    create_table :musics do |t|
      t.references :artist, foreign_key: { to_table: :artists }
      t.string :title
      t.string :album_name
      t.string :genre 
      t.timestamps
    end
  end
end
