class Threat < ActiveRecord::Base  
  require 'csv'    
  
  attr_accessible :description, :image_url, :name, :location, :latitude, :longitude
  
  has_many :comments
  
  attr_accessor :address
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode
  
  def self.get_police_data
    urls = [
      'http://www.wichitasedgwickcountycrimestoppers.com/CrimeTapeSmall.jpg',
      'http://www.uclan.ac.uk/news/assets/media/hate_crime_hand_rdax_500x500.jpg',
      'http://www.movehut.co.uk/news/wp-content/uploads/2012/01/Crime-commercial-properties-735x1024.jpg',
      'http://www.nrimalayalee.com/wp-content/uploads/2013/09/crime.jpg',
    ]
    n = 50
    while n < 60
      w = -6
      while w < 2
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
            t.image_url = urls[(0..3).to_a.sample]
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
    urls = [
      'http://roadrulesblog.files.wordpress.com/2012/02/accident.jpg',
      'http://www.mannsafety.com/images/car-ax.jpg',
      'http://i.telegraph.co.uk/multimedia/archive/01461/accident_1461384c.jpg',
      'http://www.theinjurylawyers.co.uk/injury-lawyers-blog/wp-content/uploads/2010/07/horse-road-accident.jpg'
    ]
    
    csv_text = File.read("#{Rails.root}/data/DfTRoadSafety_Vehicles_2013.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      puts row.to_hash
      puts row.to_hash["Vehicle_Type"]
      case row.to_hash["Vehicle_Type"].to_i
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
        hit = ["a previous accident", "road works", "a parked vehicle", "the roof of a bridge", "the side of a bridge", "a bollard", "an open door of another vehicle", "a roundabout", "a kerb", "another object", "an animal"][(0..10).to_a.sample]
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
      
      Threat.create!(:name => "Road accident with a #{vehicle_type}", :description => "Risk of a #{vehicle_type} coliding with #{hit} #{casualty != 'no one' ? 'injuring ' + casualty : ''}", :image_url => urls[(0..3).to_a.sample], :latitude => (500000..520000).to_a.sample.to_f / 10000, :longitude =>(-70000..20000).to_a.sample.to_f / 10000)
    end
  end
  
  def self.get_animal_data
    animals = [
      'wolf',
      'bear',
      'fox',
      'badger'
    ]
    urls = [
      'http://images.nationalgeographic.com/wpf/media-live/photos/000/005/cache/grey-wolf_565_600x450.jpg',
      'http://www.wildanimalfightclub.com/Portals/41405/images//grizzly.jpg',
      'http://www-tc.pbs.org/wnet/nature/files/2008/09/610_ag_red-fox.jpg',
      'http://2.bp.blogspot.com/-fb3nETTmvh0/Tsup45YNyGI/AAAAAAAAAoo/c6TH2VtPQoA/s1600/Angry+Badger.jpg'
    ]
    f = File.open("#{Rails.root}/data/NATIONAL_FOREST_ESTATE_RECREATION_POINTS_GB.shp.xml")
    doc = Nokogiri::XML(f)
    100.times do
      i = (0..3).to_a.sample
      Threat.create!(:latitude => doc.xpath("//northBoundLatitude").first.child.text.to_f + ((-100000..100000).to_a.sample.to_f / 10000), :longitude => doc.xpath("//westBoundLongitude").first.child.text.to_f + ((-100000..100000).to_a.sample.to_f / 10000), :name => "#{animals[i].capitalize} attack", :description => "Risk of being attacked by a #{animals[i]}", :image_url => urls[i])
    end
    f.close
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
