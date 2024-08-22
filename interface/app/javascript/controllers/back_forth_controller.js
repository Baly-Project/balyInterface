import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="back-forth"
export default class extends Controller {
  static values={currentlist:Array,currentid:Number}
  static targets=["backbtn","fwdbtn"]
  connect() {
    console.log("back-forth enabled");
  }
  removeArrows(){
    this.backbtnTarget.style.display="none"
    this.fwdbtnTarget.style.display="none"
  }
  addArrows(){
    if(!(sessionStorage["fullscreen"]=="true")){
      this.backbtnTarget.style.display="flex"
      this.fwdbtnTarget.style.display="flex"
    }
    else{
      console.log("arrows blocked")
    }
  }
  setList(){
    let stringArray=JSON.stringify(this.currentlistValue);
    sessionStorage.setItem("current-list",stringArray);
  }
  getLink(id){
    return "/slides/"+String(id)
  }
  next(){
    const currentlist=JSON.parse(sessionStorage["current-list"])
    var currentPlace = currentlist.indexOf(this.currentidValue);
    var nextvalue;
    if(currentPlace == currentlist.length-1){
      nextvalue=currentlist[0]
    }
    else{
      nextvalue=currentlist[currentPlace+1]
    }
    window.location.href=this.getLink(nextvalue);
    console.log("redirected to ", nextvalue);
  }
  prev(){
    const currentlist=JSON.parse(sessionStorage["current-list"])
    var currentPlace = currentlist.indexOf(this.currentidValue);
    var prevvalue;
    console.log(currentPlace)
    if(currentPlace==0){
      prevvalue=currentlist[currentlist.length-1];
    }
    else{
      prevvalue=currentlist[currentPlace-1]
    }
    window.location.href=this.getLink(prevvalue);
    console.log("redirected to ", prevvalue);
  }
}
