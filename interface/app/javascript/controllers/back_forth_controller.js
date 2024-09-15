import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="back-forth"
export default class extends Controller {
  static values={currentlist:Array,currentimages:Array,currentid:Number}
  static targets=["remove","back","fwd","backimg","fwdimg"]
  connect() {
    console.log("back-forth enabled")
    this.backTargets.forEach(target => {target.href=this.getLink(this.getPrev())});
    this.fwdTargets.forEach(target => {target.href=this.getLink(this.getNext())});
    this.backimgTargets.forEach(target=>{target.src=this.getImg(this.getPrev())});
    this.fwdimgTargets.forEach(target=>{target.src=this.getImg(this.getNext())});
  }
  removeArrows(){
    this.removeTargets.forEach(target=>{target.style.display="none"});
  }
  addArrows(){
    if(!(sessionStorage["fullscreen"]=="true")){
      this.removeTargets.forEach(target=>{target.style.display="flex"});
    }
    else{
      console.log("arrows blocked")
    }
  }
  setList(){
    let stringArray=JSON.stringify(this.currentlistValue);
    let imgArray=JSON.stringify(this.currentimagesValue);
    sessionStorage.setItem("current-list",stringArray);
    sessionStorage.setItem("current-images",imgArray);
  }
  getLink(id){
    return "/slides/"+String(id);
  }
  getImg(id){
    var place=JSON.parse(sessionStorage["current-list"]).indexOf(id);
    var imgNumber = JSON.parse(sessionStorage["current-images"])[place];
    return "https://digital.kenyon.edu/context/baly/article/"+String(imgNumber)+"/type/native/viewcontent";
  }
  next(){
    var nextvalue=this.getNext();
    window.location.href=this.getLink(nextvalue);
    console.log("redirected to ", nextvalue);
  }
  prev(){
    var prevvalue=this.getPrev();
    window.location.href=this.getLink(prevvalue);
    console.log("redirected to ", prevvalue);
  }
  getNext(){
    const currentlist=JSON.parse(sessionStorage["current-list"])
    var currentPlace = currentlist.indexOf(this.currentidValue);
    var nextvalue;
    if(currentPlace == currentlist.length-1){
      nextvalue=currentlist[0]
    }
    else{
      nextvalue=currentlist[currentPlace+1]
    }
    return nextvalue
  }
  getPrev(){
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
    return prevvalue
  }
}
