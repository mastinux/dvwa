## XSS (Reflected)

- https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)
- https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet
- https://en.wikipedia.org/wiki/Cross-site_scripting
- http://www.cgisecurity.com/xss-faq.html
- http://www.scriptalert1.com/

Lo script viene attivato attraverso un link, che invia una richiesta a un sito vulnerabile che permette l'esecuzione dello script malevolo.
La vulnerabilità è dovuta all'insufficiente sanitizzazione delle richieste.

Codice Vulnerabile

```
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
    // Feedback for end user
    echo '<pre>Hello ' . $_GET[ 'name' ] . '</pre>';
}
```

Exploit

```
http://localhost/vulnerabilities/xss_r/?name=Frodo <script>alert(document.cookie)</script>
```

