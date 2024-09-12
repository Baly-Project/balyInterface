import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="overflow"
export default class extends Controller {
  static targets=["wrapcontainer"];
  connect() {
    let overflower=this;
    overflower.longest=0
    overflower.wrapcontainerTargets.forEach(function(element){
      overflower.addWrapClass(element)
    })
    const resize_ob=new ResizeObserver(function(entries) {
      overflower.wrapcontainerTargets.forEach(function(element){
        overflower.addWrapClass(element)
      })
    })
    resize_ob.observe(this.wrapcontainerTarget)
  }

  addWrapClass(wrapper){
    var containerwidth=wrapper.offsetWidth
    var longest,count;
    [longest,count]=this.findLongest(wrapper);
    if(longest>this.longest){
      this.longest=longest
    }
    var overflowing=longest>containerwidth
    console.log(String(count)+" elements seen, the longest was "+String(longest))
    var msg
    if(overflowing){
      msg="this exceeds the maximum container width of "
      if(!(wrapper.classList.contains("wrap"))){
        wrapper.classList.add("wrap")
      }
    }
    else{
      msg="which is less than the container width of "
      if(this.longest < containerwidth){
        wrapper.classList.remove("wrap")
      }
    }
    console.log(msg,containerwidth)
  }
  findLongest(wrapper){
    var longest=0
    var count=0
    wrapper.querySelectorAll("a").forEach(function(element){
      var thislong=element.offsetWidth
      if(thislong > longest){
        longest=thislong
      }
      count+=1
    })
    return [longest,count]
  }
  disconnect(){
  }
}
