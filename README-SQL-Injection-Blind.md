## SQL injection (blind)

- http://www.securiteam.com/securityreviews/5DP0N1P76E.html
- https://en.wikipedia.org/wiki/SQL_injection
- http://ferruh.mavituna.com/sql-injection-cheatsheet-oku/
- http://pentestmonkey.net/cheat-sheet/sql-injection/mysql-sql-injection-cheat-sheet
- https://www.owasp.org/index.php/Blind_SQL_Injection
- http://bobby-tables.com/

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
