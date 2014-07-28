class Threat < ActiveRecord::Base
  attr_accessible :description, :image_url, :name, :location
  
  def self.get_police_data
    n = 50
    while n < 60
      w = -30
      while w < 5
        response = HTTParty.get("http://data.police.uk/api/crimes-street/all-crime?lat=#{n}&lng=#{n}=#{Time.now.strftime("%Y-%m")}")
        data = response.parsed_response
        if data.present?
          data.each do |d|
            t = Threat.new
            t.name = d["category"]
            t.description = d["outcome_status"]["category"] if d["outcome_status"]
            t.location = d["location"]["street"]["name"]
            t.save
          end
        end
        w += 0.01
      end 
      n += 0.01
    end
  end
end
