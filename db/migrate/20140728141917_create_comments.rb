class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :name
      t.string :user_name
      t.string :user_image_url
      t.belongs_to :threat

      t.timestamps
    end
    add_index :comments, :threat_id
  end
end
