# -*- coding: utf-8 -*-
require 'json'
require 'pr_geohash'
require 'pry'

Dir["./helpers/*.rb"].each { |file| require file }
Dir["./models/*.rb"].each { |file| require file }

module Clustering
  DEFAULT_PRECISION = 6
  DISTANCE = 50 # Distance in pixels
  class << self
    attr_accessor :markers, :bbox, :clusters, :center_latlng, :geohash, :size
  end

  class Cluster
    attr_accessor :center_latlng, :size, :markers
    def initialize(center_latlng, markers)
      @center_latlng = center_latlng
      @markers = markers
      @size = markers.length
    end

    def to_json(*a)
      {
        :center_latlng => @center_latlng,
        :markers => @markers,
        :size => @size
      }.to_json
    end

    def x
      @center_latlng[0]
    end

    def y
      @center_latlng[1]
    end

    #Center between this cluster and other similar to the center of mass
    #between two particles
    def center_of(cluster)
      lat = 0
      lng = 0
      factor1 = self.size
      factor2 = cluster.size
      total_factor = factor1 + factor2
      lat = ((self.center_latlng[0] * factor1) + (cluster.center_latlng[0] * factor2)) / total_factor
      lng = ((self.center_latlng[1] * factor1) + (cluster.center_latlng[1] * factor2)) / total_factor
      [lat, lng]
    end

    def add_cluster(cluster)
      @markers = @markers.concat(cluster.markers)
      @size = @size + cluster.size
      @center_latlng = self.center_of(cluster)
    end

    #TODO: Check where it comes the resolution
    def should_cluster(cluster, resolution)
      lng1 = self.x
      lat1 = self.y
      lng2 = cluster.x
      lat2 = cluster.y
      distance = GeoclusterHelper.distance_pixels(lat1, lng1, lat2, lng2, resolution)
      puts "Distance", distance
      (distance < DISTANCE)
    end

    def generate_geohash()
      geohash = GeoHash.encode(@center_latlng[0], @center_latlng[1])
    end

  end


  def self.initClusters(mks, precision, bbox, padding)
    #Getting the initial cluster configuration
    @clusters = Hash.new
    @size = mks.size
    lat_a = (mks.values.map { |m| m["lat"] }).sort
    lng_a = (mks.values.map { |m| m["lng"] }).sort
    #returns bounding box [x1,y1,x2,y2]
    #p1 = [lng_a.first - padding, lat_a.first - padding]
    #p2 = [lng_a.last + padding, lat_a.last + padding]
    #x lat, y lng

    if(bbox)
      @bbox = bbox
    else
      p1 = [lat_a.first - padding, lng_a.first - padding]
      p2 = [lat_a.last + padding, lng_a.last + padding]
      @bbox = Bbox.new(p1,p2)
    end

    #Returns a Bbox that represents the bounding box for all the coordinates
    puts "Initial bbox: #{@bbox.p1x},#{@bbox.p1y}, #{@bbox.p2x}, #{@bbox.p2y}"
    puts "Size: #{@size}"
    #binding.pry

    counter = 0
    #Initializing geohashes
    mks.each { |key, val|
      geohash = GeoHash.encode(val["lat"], val["lng"])
      val["geohash"] = geohash
      hash_key = geohash[0...precision]
      if(@clusters[hash_key])
        #puts "Original size: #{@clusters[hash_key].size}"
        #We create a new cluster using lat,lng coordinates and the marker values
        simple_cluster = Cluster.new([val["lat"], val["lng"]], [val])
        #we merged with the existing cluster
        @clusters[hash_key].add_cluster(simple_cluster)
        #puts @clusters[hash_key].size
      else
        @clusters[hash_key] = Cluster.new([val["lat"], val["lng"]], [val])
        #puts @clusters[hash_key].size
      end
    }
    p,s =  @bbox.middle_point
    @center_latlng = [p,s]
  end

  def self.load(markers)
    mks = JSON.parse(markers)
    mks = mks['markers']
    #Storing the markers
    self.markers = mks
  end

  #precision: size of the geohash
  def self.init(markers, zoom, distance, bbox=nil, padding=0.001)
    #precision should be determined by zoom and distance
    resolutions = GeoclusterHelper.resolutions()
    resolution = resolutions[zoom]

    precision = GeohashHelper.length_from_distance(distance, resolution)
    self.initClusters(markers, precision, bbox, padding)
  end

  #Cluster should be initialized
  def self.get_included(bbox)
    #p1 = [bbox[0].to_f, bbox[1].to_f]
    #p2 = [bbox[2].to_f, bbox[3].to_f]
    p1 = bbox.p1
    p2 = bbox.p2
    bounded_markers = Hash.new
    
    self.markers.each{ |key, val|
      lat, lng = val["lat"], val["lng"]
      if( (p1[0] < lat && lat <= p2[0]) && (p1[1] < lng && lng <= p2[1]) )
        bounded_markers[key] = val
      end
    }
    #binding.pry
    bounded_markers
  end


  #private
  def self.cluster_by_neighbor_check(resolution)
    #We sort the cluster by key (that means by geohash)
    sorted = @clusters.sort
    #For each geohash...
    sorted.each{ |val|
      #Current geohash
      current_key = val[0]
      #Current cluster
      current = val[1]
      #Checking if we haven't merged it
      if (@clusters[current_key] == nil )
        next
      end
      neighbors = GeohashHelper.get_top_right_neighbors(current_key)
      neighbors.each{ |n|
        if @clusters[n] != nil
          neighbor = @clusters[n]
          if (current.should_cluster(neighbor, resolution))
            puts "#{@clusters[n]} key #{n} is a neighbor of #{current_key}, #{current}"
            puts "And should been merged... merging"
            @clusters[current_key].add_cluster(neighbor)
            @clusters[n] = nil
          end
        end
      }
      #Here the key of the current key should be change according to the new center
      geohash = @clusters[current_key].generate_geohash()
      @clusters[geohash] = @clusters[current_key]
      @clusters[current_key] = nil
    }
    @clusters = @clusters.delete_if { |k, v| v.nil? }
    #binding.pry
  end

  def self.geohash_clustering_algorithm(markers, zoom = 8, distance = DISTANCE)
    self.init(markers, zoom, distance);
    #markers = self.get_included(bbox);
    resolutions = GeoclusterHelper.resolutions()
    resolution = resolutions[zoom]
    self.cluster_by_neighbor_check(resolution)
  end

end
