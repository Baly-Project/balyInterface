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
    if(!query.includes(this.laststring)) {
      this.setKeys();
    };
    var results = [];
    this.keys.forEach(element => {
      if (element.includes(query)){
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
      var anum=a.indexOf(searchstring);
      var bnum=b.indexOf(searchstring);
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
      var itemstring = "<a class='autofill dropdown-item' href='"+searchdata[result]+"'> "+result+"</a> <hr class='thinline'>";
      elements+=itemstring;
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
}
