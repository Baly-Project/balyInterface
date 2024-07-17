var activeMap=0

function logError(divid,message){
    var alert=document.getElementById(divid);
    alert.innerHTML=message;
    alert.style="display:block";
}
function clearErrors() {
    errboxes=document.querySelectorAll(".alert");
    errboxes.forEach((box)=>{
        box.innerHTML="";
        box.style="display:hidden";
    })
}

function readInput(text=0) {
    if (text==0){
        text=document.getElementById("text-input").value
    }
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

function pasteInput() {
    navigator.clipboard.readText().then(function(postitiveresult){
        readInput(postitiveresult)
        console.log("worked")
    },function(negativeResult){
        logError("err-bar-bad","Clipboard access denied, try again or use textbox")
    })
}
function displayAll() {
    outputbox=document.getElementById("output-container")
    activeMap.forEach((value,key)=>{
        outputbox.innerHTML += (
            "<span class='keyword-item' style='font-size: "+
            (value*3+70).toString()+"%;'>"+
            key+
            " </span> "
        )
    })
}

function displaySuggestions(input){
    var words=autofill(input).slice(0,20);
    if (words.length > 0){ 
        var fillHTML=""
        for (let i=0;i<(words.length-1);i++){
            var item=words[i]
            fillHTML+= "<p class='suggestion rounded' onclick='addToList(this)'>"+ item + "<span class='frequency'>("+activeMap.get(item) +")</p><hr class='suggestion-div'>"
        }
        fillHTML+="<p class='suggestion rounded' onclick='addToList(this)'>"+ words.at(-1) + "<span class='frequency'>("+activeMap.get(words.at(-1)) +")</p>"
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
searchbox.addEventListener("click",function(){
    if (searchbox.value.length == 0){
        document.getElementById("suggestions").style="display:none;"
    }
})

const wordlist=document.getElementById("list-items")
function addToList(pElement){
    removeOutline();
    var content=pElement.innerHTML;
    var word=content.slice(0,content.indexOf("<"));
    if (wordlist.innerHTML.length < 1){
        wordlist.innerHTML="<span class='list-item' onclick='deleteListElement(this)'>"+word+"</span>"
    }
    else {
        wordlist.innerHTML+="<span class='list-item' onclick='deleteListElement(this)'>, "+word+"</span>"
    }
}
function removeOutline(){
    if (Array.from(wordlist.classList).includes("outline-blue")){
        wordlist.classList.remove("outline-blue")
    }
}
function clearList(){
    removeOutline()
    wordlist.innerHTML=""
}
function deleteListElement(element) {
    removeOutline()
    var children=Array.from(wordlist.children)
    element.remove()
    if (children.indexOf(element) == 0 && children.length > 1){
        var nextelement=children.at(1)
        nextelement.innerHTML=nextelement.innerHTML.slice(2)
    }
}
function copyList(){
    var children=Array.from(wordlist.children);
    listString=new String;
    children.forEach((item)=>{
        if (item.innerHTML.length > 0) {
            listString+=item.innerHTML;
        }
    })
    wordlist.classList.add("outline-blue")
    navigator.clipboard.writeText(listString)
}
document.getElementById("key-search").addEventListener("keypress", function(e){
    if (e.key ==="Enter") {
        var suggList=document.getElementById("suggestions").children;
        pElement=Array.from(suggList).at(0);
        addToList(pElement);
        document.getElementById("key-search").value="";
        document.getElementById("suggestions").style="display:none;";
    }
})