import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="back-forth"
export default class extends Controller {
  static targets=["backbtn","fwdbtn"]
  connect() {
    console.log("back-forth enabled");
  }
  removeArrows(){
    this.backbtnTarget.style.display="none"
    this.fwdbtnTarget.style.display="none"
  }
  addArrows(){
    this.backbtnTarget.style.display="flex"
    this.fwdbtnTarget.style.display="flex"
  }

}
