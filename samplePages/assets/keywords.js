var activeMap=0

function readInput() {
    const text=document.getElementById("text-input").value
    if (text.length < 3) {
        return 0;
    }
    const rows=text.split("\n");
    const wordlist=new Map
    for (let i=0; i<rows.length; i++) {
        var row=rows[i];
        var words=row.split(",")
        for (let j=0; j<words.length; j++) {
            var word=words[j].trim()
            if (word.length > 2) {
                keys=Array.from(wordlist.keys())
                if (keys.includes(word)) {
                    var old=wordlist.get(word);
                    var update=old+1;
                    wordlist.set(word, update);
                }
                else {
                    wordlist.set(word, 1);
                }
            }    
        }
    }
    const mapSort = new Map([...wordlist.entries()].sort((a, b) => b[1] - a[1]));
    console.log(mapSort);
    activeMap = mapSort
    document.getElementById("input").style="display: none;";
    document.getElementById("output").style="";
    displayAll()
}

function displayAll() {
    outputbox=document.getElementById("output-container")
    activeMap.forEach((value,key)=>{
        outputbox.innerHTML += (
            "<span class='keyword-item' style='font-size: "+
            (value*3+70).toString()+"%;'>"+
            key+
            " </span> "+
            "<span class='spacer' style='padding:"+
            (value+5)+
            "px;'></span>"
        )
    })
}

function displaySuggestions(input){
    var words=autofill(input).slice(0,20);
    if (words.length > 0){ 
        var fillHTML=""
        for (let i=0;i<(words.length-1);i++){
            var item=words[i]
            fillHTML+= "<p class='suggestion'>"+ item + "<span class='frequency'>("+activeMap.get(item) +")</p><hr class='suggestion-div'>"
        }
        fillHTML+="<p class='suggestion'>"+ words.at(-1) + "<span class='frequency'>("+activeMap.get(words.at(-1)) +")</p>"
    }
    else {
        fillHTML="<p class='suggestion'> No Results </p>"
    }
    var suggBox=document.getElementById("suggestions")
    suggBox.style="display:block;"
    suggBox.innerHTML=fillHTML
}

function autofill(input) {
    words=Array.from(activeMap.keys());
    firstplace=new Array
    results= new Array
    words.forEach((item)=>{
        if (item.toLowerCase().includes(input.toLowerCase())){
            if (item.toLowerCase().slice(0,input.length)==input.toLowerCase()){
                firstplace.push(item)
            }
            else {
                results.push(item);
            }
        }
    })
    return firstplace.concat(results)
}
const searchbox=document.getElementById("key-search")
searchbox.addEventListener("keyup", function(){
    contents=searchbox.value
    if (contents.length > 0) {
       displaySuggestions(contents) 
    }
    else {
        document.getElementById("suggestions").style="display:none;"
    }
})