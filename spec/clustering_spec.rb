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

  it "should give the neighbors of each cluster in Clustering.clusters" do
    Clustering.geohash_clustering_algorithm(Clustering.markers)
    num_of_markers = Clustering.size
    total_markers = 0
    Clustering.clusters.each{ |key, cluster|
      total_markers = total_markers + cluster.size
    }
    expect(num_of_markers).to eq(total_markers)
  end

  it "checks the distances beetwen the clusters" do
    clusters = Clustering.clusters.values
    for i in 0...(clusters.length-1)
      j = i + 1
      lat1 = clusters[i].x
      lng1 = clusters[i].y
      lat2 = clusters[j].x
      lng2 = clusters[j].y
      #Default
      zoom = 8
      resolution = (GeoclusterHelper.resolutions())[zoom]
      puts resolution
      d = GeoclusterHelper.distance_pixels(lat1, lng1, lat2, lng2, resolution)
      #binding.pry
      puts "Distance in pixels: #{d}"
      expect(d).to be > 0
    end
    puts clusters.length
  end

  it "Should get the markers in a bbox" do
    bbox = []
  end
end
