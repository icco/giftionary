class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :username
      t.string :gif_url
      t.string :stub
      t.text :tags, array: true, default: []

      t.timestamps null: false
    end
  end
end
