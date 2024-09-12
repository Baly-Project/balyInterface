import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="orient"
export default class extends Controller {
  static targets=["img","card"]
  connect() {
    console.log("orient connected");
    console.log(this.imgTarget)
    //this.imgTarget.onload=function(e){
      var im=this.imgTarget  //e.target
      if(im.naturalHeight > im.naturalWidth){
      	this.cardTarget.classList.add("vert")
      }
    //}
  }
  disconnect() {
    console.log("disconnected")
  }
}
