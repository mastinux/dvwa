## Javascript

- https://www.w3schools.com/js/
- https://www.youtube.com/watch?v=cs7EQdWO5o0&index=17&list=WL
- https://ponyfoo.com/articles/es6-proxies-in-depth

## Javascript - Low

```
function rot13(inp) {
	return inp.replace(/[a-zA-Z]/g,function(c){return String.fromCharCode((c<="Z"?90:122)>=(c=c.charCodeAt(0)+13)?c:c-26);});
}

function generate_token() {
	var phrase = document.getElementById("phrase").value;
	document.getElementById("token").value = md5(rot13(phrase));
}
```
	
Exploit:

- genera il token corretto da `F12` -> `Console`: `md5(rot13('success'))`
- modifica il valore di `token` nella POST inserendo quello calcolato

## Javascript - Medium

```
function do_something(e) {
    for (var t = "", n = e.length - 1; n >= 0; n--) t += e[n];
    return t
}
setTimeout(function() {
    do_elsesomething("XX")
}, 300);

function do_elsesomething(e) {
    document.getElementById("token").value = do_something(e + document.getElementById("phrase").value + "XX")
}
```

Exploit:

- genera parte del token corretto da `F12` -> `Console`: `e = 'success'; for (var t = "", n = e.length - 1; n >= 0; n--) t += e[n];`
- modifica il valore di `token` nella POST inserendo quello calcolato anticipandolo e posticipandolo con `XX`

## Javascript - High

Deoffuscando parte del codice in `vulnerabilities/javascript/source/high.js` ottengo:

```
document.getElementById("phrase").value = "";

setTimeout(function () {token_part_2("XX")}, 300);

document.getElementById("send").addEventListener("click", token_part_3);

token_part_1("ABCD", 44);
```

- TODO
