import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autofill"
export default class extends Controller {
  static targets = ["fillbox","searchbox"];
  static values = { maxresults:Number};
  connect() {
    this.clearBox();
    this.assignListeners();
    console.log("autofill connected");
    this.laststring = '';
    this.setKeys()
  }
  // Setup methods
  assignListeners(){
    document.addEventListener("keyup",(e)=>{
      if(document.activeElement.id == this.searchboxTarget.id){
        this.resizePanel();
        var contents = this.searchboxTarget.value;
        if(contents.length > 0){
          this.autofill(contents);
        } else {
          this.clearBox();
        }
      }
    });
    window.addEventListener('resize', (e)=>{
      if (this.searchboxTarget.value.length > 0){
        this.resizePanel();
      }
    });
  };

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
        var itemstring = "<a class='autofill dropdown-item' href='"+link+"'> "+result+" <span class='item-type'> "+type+"</span> </a> <hr class='thinline'>";
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
    console.log("resized");
    var targetwidth = this.searchboxTarget.offsetWidth;
    this.fillboxTarget.style.visibility = 'visible';
    this.fillboxTarget.style.width = " "+targetwidth+"px";
    console.log(targetwidth);
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
