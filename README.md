Geohash Geocluster Algorithm for ruby
--------------------------------------

SUMMARY
========
Work in process...
It takes a set of markers and builds cluster based on their proximity
using geohashes.

Based on the Drupal Module [geocluster] (https://drupal.org/project/geocluster).
Jose A. Villarreal (c) 2014. Realesed under GPLv3 License


DEPENDENCIES
============
- Ruby /2.1.2p95 
- Sinatra/1.4.4 
- jQuery/1.8.3

USAGE
===== 
0. Install jQuery in public/clustering/js/
   wget http://code.jquery.com/jquery-1.8.3.min.js
1. bundle install
2. ruby server
3. Open in your browser: 
http://localhost:4567/clustering/index.html
or execute:
curl -X POST http://localhost:4567/clusters -d zoom=7 -d distance=10


