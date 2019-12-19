## CSP Bypass

- Content Security Policy Reference
- Mozilla Developer Network - CSP: script-src
- Mozilla Security Blog - CSP for the web we have

Il response header Content Security Policy (CSP) permette di ridurre i rischi di XSS sui browser moderni, dichiarando quali risorse dinamiche è consentito caricare.

Codice vulnerabile:

```
$headerCSP = "Content-Security-Policy: script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;"; // allows js from self, pastebin.com, jquery and google analytics.

...

$page[ 'body' ] .= "
    <script src='" . $_POST['include'] . "'></script>
";
```

Exploit:

- carica il codice malevolo su https://pastebin.com

- recupera l'URL per il codice RAW

- inserisci l'URL nell'`Include`

