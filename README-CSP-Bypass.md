## CSP Bypass

- https://content-security-policy.com/
- https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
- https://blog.mozilla.org/security/2014/10/04/csp-for-the-web-we-have/

L'header HTTP `Content-Security-Policy` aiuta a ridurre i rischi di XSS, dichiarando quali risorse (Javascript, immagini, CSS, richieste AJAX, frame, media html5, ...) possono essere caricate.
Esempi sono:

- `default-src 'self';`: tutto da Same Origin
- `script-src 'self';`: solo script da Same Origin
- `script-src 'self' www.google-analytics.com ajax.googleapis.com;`: solo script da Google Analytics, Google AJAX CDN e Same Origin
- `default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self';base-uri 'self';form-action 'self'`: starter policy

## CSP Bypass - Low

```
$headerCSP = "Content-Security-Policy: script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;"; // allows js from self, pastebin.com, jquery and google analytics.
```

Exploit:

- accedi a `pastebin.com`
- crea un paste contenente `alert('hacked')`
- ottieni il link al formato `raw`
- includilo nella pagina vulnerabile (`Include`)

## CSP Bypass - Medium

```
$headerCSP = "Content-Security-Policy: script-src 'self' 'unsafe-inline' 'nonce-TmV2ZXIgZ29pbmcgdG8gZ2l2ZSB5b3UgdXA=';";
```

Il `nonce` è fisso.

Exploit:

- usa il `nonce` specificato nell'header
- `<script nonce="TmV2ZXIgZ29pbmcgdG8gZ2l2ZSB5b3UgdXA=">alert('hacked')</script>`

## CSP Bypass - High

```
$headerCSP = "Content-Security-Policy: script-src 'self';";

if (isset ($_POST['include'])) {
$page[ 'body' ] .= "
    " . $_POST['include'] . "
";
}
```

```
function clickButton() {
	var s = document.createElement("script");
	s.src = "source/jsonp.php?callback=solveSum";
	document.body.appendChild(s);
}
```

Exploit:

- crea una pagina contenente un POST form con `<input type="hidden" name="include" value="<script src=&quot;source/jsonp.php?callback=alert('hacked')&quot;</script>">`

