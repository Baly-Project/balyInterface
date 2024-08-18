import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fullscreen"
export default class extends Controller {
  static targets=["body","navbox","blackbox","image","buttons","container"]


  initialize() {
    this.activated=false
    this.timer=0
  }
  connect() {
    if(this.imageTarget.innerHTML.length > 0) {
      console.log("fullscreen enabled");
      this.allbuttons=this.buttonsTarget.querySelectorAll("a");
      this.texthidden=true;
      if (this.activated) {
        this.fsActivate()
      }
    }
  }

  placebuttons(){
    var buttons=this.buttonsTarget.querySelectorAll(".fs-control");
    var img=this.imageTarget.querySelector("img");
    if (Array.from(this.navboxTarget.classList).includes("hidden")){
      console.log(window.innerWidth-img.width)
      if ((window.innerWidth-img.width)/2 < 50){
        buttons.forEach(element => {
          element.style="align-content:end";
        });
      }
      else {
        buttons.forEach(element => {
          element.style="align-content:center";
        });
      }
    }
  }

  fsActivate() {
    this.navboxTarget.classList.add("hidden");
    this.containerTarget.classList.add("hidden");
    this.blackboxTarget.classList.add("fs-backer");
    this.imageTarget.classList.add("fs-img");
    this.buttonsTarget.style="display:flex";
    console.log(this.buttonsTarget)
    this.placebuttons();
    this.activated=true;
  }

  fsDeactivate() {
    this.navboxTarget.classList.remove("hidden");
    this.containerTarget.classList.remove("hidden");
    this.blackboxTarget.classList.remove("fs-backer");
    this.imageTarget.classList.remove("fs-img");
    this.buttonsTarget.style="display:none";
    this.activated=false
  }

  fsMouseWatch(e) {
    if(!this.activated){
      return false
    }
    var ycord=e.clientY;
    var xcord=e.clientX;
    if (ycord/window.innerHeight > .75) {
      if (this.texthidden){
        $(".bottom-content").fadeIn(400);
        this.texthidden=false;
      }
    }
    else {
      if (this.texthidden == false){
        $(".bottom-content").fadeOut(400);
        this.texthidden=true;
      }
    }
    if (this.buttonsTarget.style.visibility="hidden"){
      this.buttonsTarget.style="display:flex;";
    }
    if (this.timer){clearTimeout(this.timer)};
    var allbuttons=this.buttonsTarget.querySelectorAll("a");
    var selectbutton=this.buttonsTarget.querySelector("a:hover");
    var buttonpane=this.buttonsTarget;
    this.timer = setTimeout(function(){
      console.log(allbuttons);
      if (Array.from(allbuttons).includes(selectbutton)==false){
        buttonpane.style="visibility:hidden;";
      }
    },1500)
  }
}
