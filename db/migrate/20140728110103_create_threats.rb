class CreateThreats < ActiveRecord::Migration
  def change
    create_table :threats do |t|
      t.string :name
      t.string :description
      t.string :image_url
      t.string :location

      t.timestamps
    end
  end
end
