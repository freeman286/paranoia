class Comment < ActiveRecord::Base
  belongs_to :threat
  attr_accessible :name, :user_name, :user_image_url, :threat_id
end
