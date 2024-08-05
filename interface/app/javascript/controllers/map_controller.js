import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

export default class extends Controller {
  static targets = ["container"];
  static values = { latlong: Array, labels:Array, angle:Number };

  connect() {
    this.createMap()
    this.map.fitBounds(this.latlongValue)
    for(let i=0;i<this.latlongValue.length;i++){
      this.addMarker(this.latlongValue[i],this.labelsValue[i],this.angleValue)
    }
    console.log("Info read:", this.latlongValue);
  }

  createMap() {
    var googleHybrid = L.tileLayer('http://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}',{
        maxZoom: 20,
        subdomains:['mt0','mt1','mt2','mt3']})
    var streets = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'})
    this.map = L.map(this.containerTarget, {
    layers: [streets,googleHybrid]})
    var baseMaps = {
        "Streets":streets,
        "Satellite":googleHybrid
    }

    L.control.layers(baseMaps).addTo(this.map);
  }

  addMarker(place,label,angle) {
    var hasAngle=false;
    const [latitude, longitude] = place;
    if(label.includes("Object")){
      var urlToUse = document.getElementById("green-icon").src}
    else if(label.includes("General")){
      var urlToUse = document.getElementById("blue-icon").src}
    else if(label.includes("Camera")){
      var urlToUse = document.getElementById("orange-icon").src;
      hasAngle=true;
      var fovUrl = document.getElementById("fov-icon").src;
    };
    var shadowurl = document.getElementById("shadow-icon").src;
    var icontouse = L.icon({
      iconUrl: urlToUse,
      iconSize: [30,50],
      iconAnchor: [15, 49],
      popupAnchor: [0, -35],
      shadowUrl: shadowurl,
      shadowSize: [68, 95],
      shadowAnchor: [22, 94]
    });
    var marker=L.marker([latitude, longitude], {icon: icontouse})
    //if(label.includes("Object")){
    //  icontouse=greenIcon
    //}
    //else if(label.include("Specific")){
    //  
    //}
    marker.addTo(this.map).bindPopup(label,{
      permanent: true, direction: 'top',offset:L.point(0, -5)
    })
    if(hasAngle){
      var fovIcon = L.icon({
        iconUrl: fovUrl,
        iconSize:[36,33],
        iconAnchor: [18,33],
      })
      var fovMarker=L.marker([latitude,longitude], {icon: fovIcon, rotationAngle:Number(angle)})
      fovMarker.addTo(this.map)
    }
  }


 disconnect() {
    this.map.remove();
  }
}
