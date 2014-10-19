# -*- coding: utf-8 -*-
  class GeoclusterHelper

    def self.resolutions
      r = Array.new
      max_resolution = 156.412 * 1000;
      for zoom in 1..30 do
        r[zoom] = max_resolution / (zoom * zoom)
      end
      return r
    end

    def self.distance_pixels(lat1, lng1, lat2, lng2, resolution)
      distance = self.distance_haversine(lat1, lng1, lat2, lng2)
      distance_pixels = distance / resolution * self.pixel_correction(lat1)
    end

    private
    A = 6378137
    R2D = 180 / Math::PI
    # PI = 3.1415926535
    RAD_PER_DEG = 0.017453293  #  PI/180
    # Rkm is earth’s radius in kilometers (mean radius = 6,371km)
    Rkm = 6371 # ...some algorithms use 6367
    # Rmeters is earth's radius in meters
    Rmeters = Rkm * 1000

    def self.pixel_correction(lat)
      1 + (335.0 / 223.271875276 - 1) * ((lat).abs / 47.9899)
    end

    def self.backward_mercator(x,y)
      [ x * R2D / A, ((Math::PI * 0.5) - 2.0 * Math.atan(Math.exp(-y / A))) * R2D]
    end

    #Based on http://www.codecodex.com/wiki/Calculate_Distance_Between_Two_Points_on_a_Globe#Ruby
    def self.distance_haversine(lat1, lng1, lat2, lng2)
      lat1_rad = lat1 * RAD_PER_DEG
      lng1_rad = lng1 * RAD_PER_DEG
      lat2_rad = lat2 * RAD_PER_DEG
      lng2_rad = lng2 * RAD_PER_DEG
      dlat = lat2 - lat1
      dlng = lng2 - lng2
      dlat_rad = dlat * RAD_PER_DEG
      dlng_rad = dlng * RAD_PER_DEG
      a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlng_rad)**2
      c = 2 * Math.sin(Math.sqrt(a))
      d = Rmeters * c
    end

  end
