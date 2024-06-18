const maxpages=8;
function preparray(htmlList) {
    var a=Array.from(htmlList);
    a.shift()
    a.pop()
    return a
}
function animatePager(stop=false) {
  if (stop){
    return 0
  }
  var pager=document.getElementById("pager");
  var inner=preparray(pager.children);
  var innercount=inner.length-1;
  var active=parseInt(document.querySelector(".pagination .active").innerHTML)-1;
  var target=Math.floor(maxpages/2);
  if (active < target){
    active=target;
  }
  if (innercount-active < target){
    active=innercount-target;
  }
  for (let i=0;i<innercount+1;i++) {
    var dist=Math.abs(i-active);
    //console.log("i=", i, "dist=", dist)
    if (dist > target){
      inner[i].style.display = "none"
    }
    else if (dist==target && i!=0 && i!=innercount){
      inner[i].children[0].innerHTML="..."
    }
  }
}

animatePager(true)
