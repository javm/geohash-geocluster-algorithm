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
  Clustering.load(@markers)
  #Clustering.init(@markers, zoom, 50)
end

get '/' do
  "{title: Clustering Markers}"
  #binding.pry
end

post '/clusters' do
  @bbox = nil
  if params[:bbox]
    bbox = params[:bbox];
    p1 = [bbox[0].to_f, bbox[1].to_f]
    p2 = [bbox[2].to_f, bbox[3].to_f]
    @bbox = Bbox.new(p1,p2)
    #binding.pry
    markers = Clustering.get_included(@bbox);
  end
  markers = markers || Clustering.markers

  zoom = params[:zoom].to_i
  distance = params[:distance].to_f
  Clustering.init(markers, zoom, distance, @bbox)

  res = Hash.new
  Clustering.geohash_clustering_algorithm(markers, zoom, distance)
  res["clusters"] = Clustering.clusters
  res["centerLatLng"] = Clustering.center_latlng
  res.to_json
end
