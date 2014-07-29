class AddLatAndLong < ActiveRecord::Migration
  def change
    add_column :threats, :latitude, :float
    add_column :threats, :longitude, :float
  end
end
