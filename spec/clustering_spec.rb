require "spec_helper"
require "rspec/expectations"

describe Clustering do
  before :all do
    @markers = File.read("markers.json")
    #puts @markers
    Clustering.load(@markers)
    Clustering.init(Clustering.markers, 8, 20)
    D = Clustering::DISTANCE
  end

  it "should get the clusters as a Hash" do
    #puts Clustering.markers
    expect(Clustering.clusters).to be_a Hash
    num_of_markers = Clustering.size
    total_markers = 0
    #binding.pry
    Clustering.clusters.each{ |key, cluster|
      #puts key
      total_markers = total_markers + cluster.size
    }
    expect(num_of_markers).to eq(total_markers)
  end

  it "arranges the clusters using the algorithm" do
    Clustering.geohash_clustering_algorithm(Clustering.markers)
    num_of_markers = Clustering.size
    total_markers = 0
    Clustering.clusters.each{ |key, cluster|
      total_markers = total_markers + cluster.size
    }
    expect(num_of_markers).to eq(total_markers)

    #The default zoom is 8
    zoom = 8
    #same first lines of code that are in Clustering.init
    resolutions = GeoclusterHelper.resolutions()
    resolution = resolutions[zoom]
    distance = 50
    Clustering.init(Clustering.markers, zoom, distance);
    precision = GeohashHelper.length_from_distance(distance, resolution)

    Clustering.markers.each { |key, val|
      geohash = GeoHash.encode(val["lat"], val["lng"])
      hash_key = geohash[0...precision]
      items = Clustering.clusters[hash_key].markers
      expect(val).to be_an_instance_of(Hash)
      expect(items).to be_an_instance_of(Array)
      #binding.pry
      out = items.select {|item| item["id"] == val["id"]}
      #puts out
      expect(out.size).to be_equal(1)
      out = out[0]
      #p "out: #{out}", "val: #{val}"

      expect(out["lat"]).to be_equal(val["lat"])
      expect(out["lng"]).to be_equal(val["lng"])
    }

  end


  it "checks the distances beetwen the clusters" do
    clusters = Clustering.clusters.values
    zoom = 8
    for i in 0...(clusters.length-1)
      j = i + 1
      lat1 = clusters[i].x
      lng1 = clusters[i].y
      lat2 = clusters[j].x
      lng2 = clusters[j].y
      #Default

      resolution = (GeoclusterHelper.resolutions())[zoom]
      puts resolution
      d = GeoclusterHelper.distance_pixels(lat1, lng1, lat2, lng2, resolution)
      #binding.pry
      puts "Distance in pixels: #{d}"
      expect(d).to be > 0
    end
    puts clusters.length
  end


  it "gets the markers in a bbox" do
    p1 = [56.1845141080236, 7.788947644531277]
    p2 = [57.15632264576221, 11.529792371093777]
    bbox = Bbox.new(p1, p2)
    included = Clustering.get_included(bbox)
    markers = included.values
    isIn = true
    for i in 0...(markers.length-1)
      lat, lng = markers[i]['lat'], markers[i]['lng']
      #puts "#{lat}, #{lng}"
      isIn = ((p1[0] < lat) && (lat <= p2[0]) && (p1[1] < lng) && (lng <= p2[1])) && isIn
    end
    expect(isIn).to be true
  end
end
