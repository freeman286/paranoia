class Threat < ActiveRecord::Base
  attr_accessible :description, :image_url, :name, :location
  
  has_many :comments
  
  def self.get_police_data
    n = 50
    while n < 60
      w = -30
      while w < 5
        response = HTTParty.get("http://data.police.uk/api/crimes-street/all-crime?lat=#{n}&lng=#{w}&date=2013-01")
        data = response.parsed_response
        if data.present?
          data.each do |d|
            t = Threat.new
            t.name = d["category"]
            t.description = d["outcome_status"]["category"] if d["outcome_status"]
            t.location = "#{d["location"]["latitude"]}-#{d["location"]["longitude"]}"
            t.save
            t
          end
        end
        puts "#{n}-#{w}"
        w += 1.to_f / 69.to_f
      end 
      n += 1.to_f / 69.to_f
    end
  end
  
  def self.find_by_lat_long(lat, long)
    threats = []
    Threat.all.each do |threat|
      x = threat.location.index("-")
      tlat = threat.location[0..x-1].to_f
      tlong = threat.location[x+1..-1].to_f
      if (lat - 1 < tlat) && (tlat < lat + 1) && (long - 1 < tlong) && (tlong < long + 1)
        threats << threat
      end 
    end
    threats
  end
end
