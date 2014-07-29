class Threat < ActiveRecord::Base  
  require 'csv'    
  
  attr_accessible :description, :image_url, :name, :location, :latitude, :longitude
  
  has_many :comments
  
  attr_accessor :address
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode
  
  def self.get_police_data
    n = 50
    while n < 52
      w = -30
      while w < 5
        response = HTTParty.get("http://data.police.uk/api/crimes-street/all-crime?lat=#{n}&lng=#{w}&date=2013-01")
        data = response.parsed_response
        if data.present?
          data.each do |d|
            t = Threat.new
            t.name = d["category"]
            t.description = d["outcome_status"]["category"] if d["outcome_status"]
            t.location = d["location"]["street"]["name"] if d["location"]["street"]
            t.latitude = d["location"]["latitude"].to_f
            t.longitude = d["location"]["longitude"].to_f
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
  
  def self.get_road_data
    csv_text = File.read("#{Rails.root}/data/DfTRoadSafety_Vehicles_2013.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      puts row.to_hash
      puts row.to_hash["Vehicle_Reference"]
      case row.to_hash["Vehicle_Reference"].to_i
      when 1
        vehicle_type = "bicycle"
      when 2..5
        vehicle_type = "motorbike"
      when 8, 9, 23, 97
        vehicle_type = "car"
      when 10..11
        vehicle_type = "bus"
      when 16
        vehicle_type = "horse"     
      when 17
        vehicle_type = "tractor"
      when 18
        vehicle_type = "tram"
      when 19..21
        vehicle_type = "van"
      when 19..21
        vehicle_type = "van"
      when 22
        vehicle_type = "mobility scooter"
      else
        vehicle_type = "vehicle"
      end
      
      puts row.to_hash["Hit_Object_in_Carriageway"]
      case row.to_hash["Hit_Object_in_Carriageway"].to_i
      when 0
        hit = "nothing"
      when 1
        hit = "a previous accident"
      when 2
        hit = "road works"
      when 4
        hit = "a parked vehicle"
      when 5
        hit = "the roof of a bridge"
      when 6
        hit = "the side of a bridge"
      when 7
        hit = "a bollard"
      when 8
        hit = "an open door of another vehicle"
      when 9
        hit = "a roundabout"
      when 10
        hit = "a kerb"
      when 11
        hit = "another object"
      when 12
        hit = "an animal"
      else
        hit = "nothing"
      end
      
      puts row.to_hash["Vehicle_Reference"]
      case row.to_hash["Vehicle_Reference"].to_i
      when 1
        casualty = "the driver"
      when 2
        casualty = "a passenger"
      when 3
        casualty = "a pedestrian"
      else
        casualty = "no one"
      end
      
      Threat.create!(:name => "Road accident with a #{vehicle_type}", :description => "Risk of a #{vehicle_type} coliding with #{hit} #{casualty != 'no one' ? 'injuring ' + casualty : ''}", :latitude => (500000..520000).to_a.sample.to_f / 10000, :longitude =>(-70000..20000).to_a.sample.to_f / 10000)
    end
  end
  
  def location_to_lat_long!
    self.latitude = self.location.match(/(-?\d{1,2}.\d{6})-(-?\d{1,2}.\d{6})/)[1]
    self.longitude = self.location.match(/(-?\d{1,2}.\d{6})-(-?\d{1,2}.\d{6})/)[2]
    self.save
  end
  
  def self.find_by_lat_long(lat, long)
    Threat.near([lat, long], 1)
  end
end
