class AddMimetype < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :mimetype, :string
  end
end
