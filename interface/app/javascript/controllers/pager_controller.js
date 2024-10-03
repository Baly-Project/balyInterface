import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pager"
export default class extends Controller {
  static targets=["pager"];

  MaxPages=8;

  connect() {
    this.pagerTargets.forEach(pager=>{
      this.animatePager(pager);
    })
  }

  prepArray(htmlList) {
    var a=Array.from(htmlList);
    var first=a.shift();
    var last=a.pop();
    return [a,first,last];
  }

  prepSkipper(toLink,linkSource) {
    var link=linkSource.children[0].href;
    toLink.children[0].href=link;
  }

  animatePager(pager) {
    var children=pager.children;
    var inner,first,last
    [inner,first,last]=this.prepArray(children);

    var innercount=inner.length-1;
    var active=parseInt(pager.querySelector(".page-link.active").innerHTML)-1;
    var target=Math.floor(this.MaxPages/2);

    if (active < target){
      active=target;
    }
    if (innercount-active < target){
      active=innercount-target;
    }

    for (let i=0;i<innercount+1;i++) {
      var dist=Math.abs(i-active);
      //console.log("i=", i, "dist=", dist)
      if (dist <= target){
        //console.log("this should be hidden",inner.at(i));
        inner.at(i).style.display = "block";
        if (dist==target && i!=0 && i!=innercount){
          inner.at(i).children[0].innerHTML="..."
        }
      }
    }
    this.prepSkipper(first,inner.at(0));
    this.prepSkipper(last,inner.at(-1));

  }
}
