var target = "http://localhost:4567/custers";

function initClusters(jQueryObj, googleMapsObj, params){
  jQueryObj.post(target,
	 params,
	 function(data){
	   var c = data["centerLatLng"];
	   var mapOptions = {
	     zoom: 8,
	     center: new googleMapsObj.LatLng(c[0], c[1])
	     //center: myLatlng
	   };
	   var map = new googleMapsObj.Map(document.getElementById('map-canvas'), mapOptions);
	   var clusters = data["clusters"];
	   Object.keys(clusters).forEach(function(key){
             var obj = clusters[key];
             //alert(obj["center_latlng"]);
             var lat = obj["center_latlng"][0];
             var lng = obj["center_latlng"][1];
             var sz = obj["size"];
             var latlng = new googleMapsObj.LatLng(lat, lng);
             new googleMapsObj.Marker({
               position: latlng,
               map: map,
               title: sz.toString()
             });
	   });
	 }, "json");
}
