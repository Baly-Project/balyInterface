import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {

  static targets=["textbox"]
  connect() {
    console.log("search enabled")
  }


  submit() {
    var qstring=this.textboxTarget.value;
    if(String(qstring).length > 0){
      var uristring=encodeURI(qstring);
      window.location.href="/search/"+uristring;
    }
  }
}
