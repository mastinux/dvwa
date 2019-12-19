## File upload

- https://www.owasp.org/index.php/Unrestricted_File_Upload
- https://blogs.securiteam.com/index.php/archives/1268
- https://www.acunetix.com/websitesecurity/upload-forms-threat/

L'attaccante carica un file a suo piacimento per poi eseguirlo in altro modo.
L'attaccante può sovrascrivere file già presenti sul server sfruttando path e filename presenti nei metadati HTTP.
Altri problemi si hanno se dimensione o contenuto del file vengono manipolati.

- crea un file fu.php col seguente contenuto

```
<?php
 
phpinfo();

?>
```

- carica il file tramite la funzione

- visita `http://localhost/hackable/uploads/fu.php`

