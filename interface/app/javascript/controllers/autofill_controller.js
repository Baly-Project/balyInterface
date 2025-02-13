import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autofill"
export default class extends Controller {
  static targets = ["fillbox","searchbox"];
  static values = { maxresults:Number, override:String };
  connect() {
    this.clearBox();
    this.assignListeners();
    console.log("autofill connected");
    this.laststring = '';
    this.setKeys()
  }
  // Setup methods
  assignListeners(){
    var searchbar = this.searchboxTarget
    document.addEventListener("keyup",(e)=>{
      if(document.activeElement.id == searchbar.id){
        this.resizePanel();
        var contents = searchbar.value;
        if(contents.length > 0){
          this.autofill(contents);
        } else {
          this.clearBox();
        }
      }
    });
    window.addEventListener('resize', (e)=>{
      if (searchbar.value.length > 0){
        this.resizePanel();
      }
    });

    searchbar.addEventListener("click", (e)=>{
      setTimeout(()=>this.clearIfEmpty(), 100);
    });
  }

  clearIfEmpty(){
    var contents = this.searchboxTarget.value;
    if(contents.length == 0){
      this.clearBox();
    } else {
      this.resizePanel();
    }
  }

  setKeys(){
    this.keys = Object.keys(searchdata);
  }

  // Search methods
  autofill(query){
    if(!query.includes(this.laststring) || !this.keys) {
      this.setKeys();
    };
    var results = [];
    this.keys.forEach(element => {
      if (element.toLowerCase().includes(query.toLowerCase())){
        results.push(element)
      }
    });
    this.prepareElements(results,query)
    this.keys = results;
    this.laststring = query;
  }

  // Target Manipulators

  prepareElements(array,searchstring){
    array.sort(function(a,b){
      var anum=a.toLowerCase().indexOf(searchstring.toLowerCase());
      var bnum=b.toLowerCase().indexOf(searchstring.toLowerCase());
      if (anum < bnum){
        return -1;
      } else if (anum > bnum){
        return 1;
      }
      return 0;
    })
    var topN = array.slice(0,this.maxresultsValue+1)
    var elements =  ''
    topN.forEach(result => {
      searchdata[result].forEach(link => {
        var type = this.getType(link)
        var itemstring = "<li><a class='autofill dropdown-item' href='"+link+"'> "+result+" <span class='item-type'> "+type+"</span> </a></li> <hr class='thinline'>";
        elements+=itemstring;
      })
    })
    this.fillboxTarget.innerHTML = elements
  }

  clearBox(){
    this.fillboxTarget.innerHTML = '';
    this.fillboxTarget.style.visibility = 'hidden';
  }

  resizePanel(){
    var fillbox = this.fillboxTarget;
    fillbox.style.visibility = 'visible';
    if(window.innerWidth < 1200 || this.overrideValue == "resize") {
      var targetwidth = this.searchboxTarget.offsetWidth;
      fillbox.style.width = " "+targetwidth+"px";
    } else {
      fillbox.style.width = "";
    }
  }

  getType(link) {
    const linkIdentifiers = ['collections','keywords','locations','cities','regions','countries','stamps','years'];
    const types = ['Collection','Keyword','Location','City','Region','Country','Stamp','Year'];
    var index=0;
    while(index < linkIdentifiers.length){
      if(link.includes(linkIdentifiers[index])){
        return types[index];
      }
      index++;
    }
    return 'Typing Error';
  }
}
