## Insecure CAPTCHA

- https://en.wikipedia.org/wiki/CAPTCHA
- https://www.google.com/recaptcha/
- https://www.owasp.org/index.php/Testing_for_Captcha_(OWASP-AT-012)

Il codice fa il controllo sul valore di `$_POST[ 'step' ]`.
Se vale `1` valuta il CAPTCHA, diversamente (`2`) esegue l'operazione di cambio password.

- modifico il valore di `step` a `2` e inserisco la password di mio piacimento (il codice non entra nel ramo if che controlla il CAPTCHA)

