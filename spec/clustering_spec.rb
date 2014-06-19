require "spec_helper"
require "rspec/expectations"

describe Clustering do
  before :all do
    @markers = File.read("markers.json")
    #puts @markers
    Clustering.init(@markers)
  end

  it "should get the clusters as a Hash" do
    #puts Clustering.markers
    expect(Clustering.clusters).to be_a Hash
    num_of_markers = Clustering.size
    total_markers = 0
    #binding.pry
    Clustering.clusters.each{ |key, cluster|
      puts key
      total_markers = total_markers + cluster.size
    }
    expect(num_of_markers).to eq(total_markers)
  end

  it "should give the neighbors of each cluster in Clustering.clusters" do
    Clustering.geohash_clustering_algorithm(@markers)
    num_of_markers = Clustering.size
    total_markers = 0
    Clustering.clusters.each{ |key, cluster|
      total_markers = total_markers + cluster.size
    }
    expect(num_of_markers).to eq(total_markers)
  end
end
