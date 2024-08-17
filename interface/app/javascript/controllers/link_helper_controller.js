import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="link-helper"
export default class extends Controller {
  static targets=["linkbox"];
  static values={ helpwith:Object };

  connect() {
    for (const [key, value] of Object.entries(this.helpwithValue)) {
      console.log(this.linkboxTarget.textContent)
      var text=this.linkboxTarget.textContent;
      console.log(key,text.includes(key));
      if(text.includes(key)) {
        this.linkboxTarget.innerHTML=this.linkboxTarget.innerHTML.replace(key,"<a class='purple' href='"+value+"'>"+ key +"</a>")
      }
    }
  }
}
