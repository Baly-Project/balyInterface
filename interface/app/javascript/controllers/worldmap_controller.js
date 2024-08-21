import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

export default class extends Controller {
  static targets = ["container"];
  static values = { latlong: Array, labels:Array, scales:Array};

  connect() {
    this.createMap()
    this.map.setView([25,0],3)
    for(let i=0;i<this.latlongValue.length;i++){
      this.addMarker(this.latlongValue[i],this.labelsValue[i],this.scalesValue[i])
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

  addMarker(place,label,scale) {
    var hasAngle=false;
    const [latitude, longitude] = place;
    var urlToUse = document.getElementById("blue-icon").src
    var shadowurl = document.getElementById("shadow-icon").src;
    var icontouse = L.icon({
      iconUrl: urlToUse,
      iconSize: [scale*36,scale*60],
      iconAnchor: [scale*18, scale*60-1],
      popupAnchor: [0, -scale*35],
      shadowUrl: shadowurl,
      shadowSize: [scale*68, scale*95],
      shadowAnchor: [scale*22, scale*94]
    });
    var marker=L.marker([latitude, longitude], {icon: icontouse})
    console.log(label)
    marker.addTo(this.map).bindPopup(label,{
      permanent: true, direction: 'top',offset:L.point(0, -5)
    })
  }


 disconnect() {
    this.map.remove();
  }
}
