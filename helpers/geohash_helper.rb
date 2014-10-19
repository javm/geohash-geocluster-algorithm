  GEOHASH_PRECISION = 12
  class GeohashHelper

    #Gives the geohash neighbors using the GeoHash.adjacent function
    def self.get_top_right_neighbors(geohash)
      neighbors = Array.new(4)
      top = GeoHash.adjacent(geohash, :top)
      neighbors[0] = GeoHash.adjacent(top, :left)
      neighbors[1] = top
      neighbors[2] = GeoHash.adjacent(top, :right)
      neighbors[3] = GeoHash.adjacent(geohash, :right)
      neighbors
    end

    #Calculates the length of the GeoHash depending on the distance between clusters in pixels
    def self.length_from_distance(distance, resolution)
      cluster_distance_meters = distance * resolution
      x = y = cluster_distance_meters
      width, height = GeoclusterHelper.backward_mercator(x, y)
      hash_len = GeohashHelper.lookup_hash_len_for_width_height(width, height)
      hash_len + 1
    end

    #Return a geohash length that has width & height >= specified arguments.
    #
    # based on solr2155.lucene.spatial.geohash.GeoHashUtils
    def self.lookup_hash_len_for_width_height(width, height)
      hash_len_to_lat_height, hash_len_to_lon_width = GeohashHelper.get_hash_len_conversions
      #Loop through hash length arrays from beginning till we find one.
      for len in 1..GEOHASH_PRECISION
        lat_height = hash_len_to_lat_height[len]
         lon_width = hash_len_to_lon_width[len]
        if(lat_height < height || lon_width < width)
          return len - 1
        end
      end
      return GEOHASH_PRECISION
    end

   # based on solr2155.lucene.spatial.geohash.GeoHashUtils
   # See the table at http://en.wikipedia.org/wiki/Geohash
   def self.get_hash_len_conversions
     hash_len_to_lat_height = [90*2]
     hash_len_to_lon_width = [180*2]
     even = false;
     for i in 1..GEOHASH_PRECISION
       hash_len_to_lat_height[i] = hash_len_to_lat_height[i-1] / ( even ? 8 : 4)
       hash_len_to_lon_width[i] = hash_len_to_lon_width[i - 1] / ( even ? 4 : 8)
       even = !even
     end
     [hash_len_to_lat_height, hash_len_to_lon_width]
   end

  end
