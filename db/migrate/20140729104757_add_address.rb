class AddAddress < ActiveRecord::Migration
  def change
    add_column :threats, :address, :string
  end
end
