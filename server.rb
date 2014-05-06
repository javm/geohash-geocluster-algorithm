# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader'
#require 'sinatra/jsonp'
require 'sinatra/multi_route'
require 'json'
require 'pry'

#Requiring the clustering module
require_relative 'clustering'

configure do
  enable :sessions
end

#Setting the response Content-Type header to 'application/json'
before do
  content_type :json
  @markers = File.read("markers.json")
  #puts @markers
  Clustering.init(@markers)
end

get '/' do
  "{title: Clustering Markers}"
  #binding.pry
end

get '/clusters' do
  res = Hash.new;

  for geohash, c1 in Clustering.clusters
    neighbors = Clustering.get_geohash_neighbors(c1, Clustering.clusters)
    for c2 in neighbors do
      if shouldCluster(c1, c2, distance)
        mergeClusters(Clustering.clusters, c1, c2)
      end
    end
  end

  res["clusters"] = Clustering.clusters
  res["centerLatLng"] = Clustering.center_latlng
  res.to_json
end


