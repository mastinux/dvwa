## Weak session IDs

<!-- ??? -->

## Weak session IDs - Low

```
if (!isset ($_SESSION['last_session_id'])) {
	$_SESSION['last_session_id'] = 0;
}
$_SESSION['last_session_id']++;
```

Exploit:

- cattura la richiesta generata cliccando su `Generate` tramite Burp Suite
- tasto destro sulla richiesta e `Send to Sequencer`
- `Sequencer` -> `Start live capture`
- attendere la fine della cattura e `Analyze now`
- risultato:

```
The overall quality of randomness within the sample is estimated to be: extremely poor.
At a significance level of 1%, the amount of effective entropy is estimated to be: 0 bits.
```

## Weak session IDs - Medium

```
if ($_SERVER['REQUEST_METHOD'] == "POST") {
	$cookie_value = time();
	setcookie("dvwaSession", $cookie_value);
} 
```

Exploit:

- ripeto gli stessi passi del livello low
- ottengo lo stesso risultato

## Weak session IDs - High

```
$cookie_value = md5($_SESSION['last_session_id_high']);
setcookie("dvwaSession", $cookie_value, time()+3600, "/vulnerabilities/weak_id/", $_SERVER['HTTP_HOST'], false, false);
```

Exploit: non sfruttabile

