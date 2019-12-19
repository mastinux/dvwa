## SQL injection

- http://www.securiteam.com/securityreviews/5DP0N1P76E.html
- https://en.wikipedia.org/wiki/SQL_injection
- http://ferruh.mavituna.com/sql-injection-cheatsheet-oku/
- http://pentestmonkey.net/cheat-sheet/sql-injection/mysql-sql-injection-cheat-sheet
- https://www.owasp.org/index.php/SQL_Injection
- http://bobby-tables.com/

Devo iniettare del codice che verifichi la condizione WHERE.

Codice vulnerabile:

`$query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";`

Exploit:

`' or 'a' = 'a`
