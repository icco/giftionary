class NewColumns < ActiveRecord::Migration
  def change
    change_table :images do |t|
      t.remove :tags
      t.string :description
      t.rename :gif_url, :url
    end
  end
end
