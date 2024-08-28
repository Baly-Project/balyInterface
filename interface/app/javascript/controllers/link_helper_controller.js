import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="link-helper"
export default class extends Controller {
  static targets=["linkbox"];
  static values={ helpwith:Object };

  connect() {
    this.linkboxTargets.forEach(target=>{
      for (const [key, value] of Object.entries(this.helpwithValue)) {
        console.log(target.textContent)
        var text=target.textContent;
        console.log(key,text.includes(key));
        if(text.includes(key)) {
          target.innerHTML=target.innerHTML.replace(key,"<a class='purple' href='"+value+"'>"+ key +"</a>")
        }
      }
    })
  }
}
