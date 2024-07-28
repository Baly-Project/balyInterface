window.onload=function(){
      var texthidden=true;
      var buttonpane=document.querySelector(".tophalf");
      var allbuttons=document.querySelectorAll(".tophalf a");
      var timer;

      function fsMouseWatch(e){
        var ycord=e.clientY;
        var xcord=e.clientX;
        if (ycord/window.innerHeight > .75) {
          if (texthidden){
            $(".bottom-content").fadeIn(400);
            texthidden=false;
          }
        }
        else {
          if (texthidden == false){
            $(".bottom-content").fadeOut(400);
            texthidden=true;
          }
        }
        if (buttonpane.style.visibility="hidden"){
          buttonpane.style="visibility:normal;";
        }
        if (timer){clearTimeout(timer)};
        timer = setTimeout(function(){
          if (Array.from(allbuttons).includes(document.querySelector("a:hover"))==false){
            buttonpane.style="visibility:hidden;";
          }
        },1500)
      }

      var buttons=document.querySelectorAll(".fs-control")
      var img=document.querySelector("#imgCarousel img")
      var otherelement=document.querySelector(".navbox")
      function placebuttons(){
        if (Array.from(otherelement.classList).includes("hidden")){
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

      function fullscreen(){
        $(".navbox")[0].classList.add('hidden');
        $(".container")[0].classList.add('hidden');

        $("#blackbox")[0].classList.add("fs-backer");
        $("#imgCarousel")[0].classList.add("fs-img");
        $("#buttons-pane")[0].style="display:flex";
        document.addEventListener("mousemove", fsMouseWatch);
        placebuttons();
      }
      var fsButton=document.getElementById("fullscreen-button");
      if (sessionStorage['fullscreen']){
        fullscreen();
      }
      fsButton.addEventListener("click",function(){
        sessionStorage.setItem("fullscreen",true);
        fullscreen()
      })
      function emptyscreen(){
        $(".navbox")[0].classList.remove('hidden');
        $(".container")[0].classList.remove('hidden');

        $("#blackbox")[0].classList.remove("fs-backer");
        $("#imgCarousel")[0].classList.remove("fs-img");
        $("#buttons-pane")[0].style="display:none";
        document.removeEventListener("mousemove", fsMouseWatch);
      }
      document.getElementById("exit-fullscreen").addEventListener("click", function(){
        sessionStorage.removeItem("fullscreen");emptyscreen()})

      window.onresize=placebuttons;

      window.addEventListener("keypress", function(e){
        if (e.key === "f4"){
          fullscreen();
          }
        else if (e.key === "f5") {
          emptyscreen();
        }
      })
      if (sessionStorage["fullscreen"]){
        document.getElementById("blackscreen").style.display="none";
      }
}
