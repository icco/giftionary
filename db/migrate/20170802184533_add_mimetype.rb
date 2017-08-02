class AddMimetype < ActiveRecord::Migration
  def change
    add_column :images, :mimetype, :string
  end
end
