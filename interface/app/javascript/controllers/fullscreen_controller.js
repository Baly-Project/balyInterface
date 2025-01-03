import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fullscreen"
export default class extends Controller {
  static targets=["body","navbox","blackbox","image","buttons","container"]


  initialize() {
    this.activated=false
    this.timer=0
  }
  connect() {
    var interval = setInterval(()=>{
      try {
        this.setup();
        clearInterval(interval);
      } catch(e) {
        console.log('failed attempt',e)
      }
    }, 200);
  }

  setup(){
    this.buttons=this.buttonsTarget.querySelectorAll(".fs-control");
    this.img=this.imageTarget.querySelector("img");
    if(this.imageTarget.innerHTML.length > 0) {
      console.log("fullscreen enabled");
      this.allbuttons=this.buttonsTarget.querySelectorAll("a");
      this.texthidden=true;
      if (sessionStorage["fullscreen"]=="true") {
        sessionStorage["reload-map"]="true";
        this.fsActivate();
        let fs=this
        window.onload=function(){
          fs.placebuttons();
          console.log("IT WORKED")
        }
        document.getElementById("blackscreen").style.display="none";
        console.log("fullscreen migrated");
      }
    }
  }

  placebuttons(){
    console.log(window.innerWidth-this.img.width)
    if ((window.innerWidth-this.img.width)/2 < 50){
      this.buttons.forEach(element => {
        element.style="align-content:end";
      });
    }
    else {
      this.buttons.forEach(element => {
        element.style="align-content:center";
      });
    }
    console.log("buttons placed");
  }

  fsActivate() {
    this.navboxTarget.classList.add("hidden");
    this.containerTarget.classList.add("hidden");
    this.blackboxTarget.classList.add("fs-backer");
    this.imageTarget.classList.add("fs-img");
    this.buttonsTarget.style="display:flex";
    console.log(this.buttonsTarget)
    this.placebuttons();
    sessionStorage["fullscreen"]='true';
  }

  fsDeactivate() {
    this.navboxTarget.classList.remove("hidden");
    this.containerTarget.classList.remove("hidden");
    this.blackboxTarget.classList.remove("fs-backer");
    this.imageTarget.classList.remove("fs-img");
    this.buttonsTarget.style="display:none";
    sessionStorage["fullscreen"]='false';
  }

  fsMouseWatch(e) {
    if(!(sessionStorage["fullscreen"]=="true")){
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
    var allbuttons=this.buttonsTarget.querySelectorAll("a, .bottomtext");
    var selectbutton=this.buttonsTarget.querySelector("a:hover,.bottomtext:hover");
    var buttonpane=this.buttonsTarget;
    this.timer = setTimeout(function(){
      console.log(allbuttons);
      if (Array.from(allbuttons).includes(selectbutton)==false){
        buttonpane.style="visibility:hidden;";
      }
    },1500)
  }
}
