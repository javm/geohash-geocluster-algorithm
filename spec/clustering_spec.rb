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
  end

  it "should give the neighbors of each cluster in Clustering.clusters" do
    Clustering.cluster_by_neighbor_check
  end
end
