import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

export default class extends Controller {
  static targets = ["container"]
  static values = { latlong: Array, labels:Array }


  connect() {
    this.createMap()
    this.map.fitBounds(this.latlongValue)
    for(let i=0;i<this.latlongValue.length;i++){
      this.addMarker(this.latlongValue[i],this.labelsValue[i])
    }
    console.log("Info read:", this.latlongValue);
  }

  createMap() {
    this.map = L.map(this.containerTarget)

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.map);
  }

  addMarker(place,label) {
    const [latitude, longitude] = place;
    L.marker([latitude, longitude])
      .addTo(this.map)
      .bindPopup(label,{permanent: true, direction: 'top',offset:L.point(0, -5)})
  }


 disconnect() {
    this.map.remove();
  }
}
