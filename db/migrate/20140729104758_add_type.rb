class AddType < ActiveRecord::Migration
  def change
    add_column :threats, :type, :string
  end
end
