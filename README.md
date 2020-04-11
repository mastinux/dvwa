
- DVWA Attacks
  - [Brute force](./README-Brute-Force.md)
  - [Command injection](./README-Command-Injection.md)
  - [CSRF](./README-CSRF.md)
  - [File inclusion](./README-File-Inclusion.md)
  - [File upload](./README-File-Upload.md)
  - [Insecure CAPTCHA](./README-Insecure-CAPTCHA.md)
  - [SQL injection](./README-SQL-Injection.md)
  - [SQL injection (blind)](./README-SQL-Injection-Blind.md)
  - [Weak session IDs](./README-Weak-Session-IDs.md)
  - [XSS (DOM)](./README-XSS-DOM.md)
  - [XSS (Reflected)](./README-XSS-Reflected.md)
  - [XSS (Stored)](./README-XSS-Stored.md)
  - [CSP Bypass](./README-CSP-Bypass.md)
  - [Javascript](./README-JavaScript.md)
- [DVWA configuration](#dvwa-configuration)
- [Man pages](#man-pages)

TODO https://owasp.org/www-project-web-security-testing-guide/latest/

# DVWA Configuration

- DVWA
	- Host: 172.17.0.2
	- Default credentials: admin/password

- PHP web server
	- Host: 172.17.0.3

# Man pages

curl

	```
	-s, --silent
		Silent or quiet mode. Don't show progress meter or error messages. Makes Curl mute. It will still output the data you ask for, potentially even to the terminal/stdout unless you redirect it.
		Use -S, --show-error in addition to this option to disable progress meter but still show error messages.
		See also -v, --verbose and --stderr.

	-b, --cookie <data|filename>
		(HTTP) Pass the data to the HTTP server in the Cookie header. It is supposedly the data previously received from the server in a "Set-Cookie:" line. The data should be in the format "NAME1=VALUE1; NAME2=VALUE2".

	-c, --cookie-jar <filename>
		(HTTP) Specify to which file you want curl to write all cookies after a completed operation. Curl writes all cookies from its in-memory cookie storage to the given file at the end of operations. If no cookies are known, no data will be written. The file will be written using the Netscape cookie file format. If you set the file name to a single dash, "-", the cookies will be written to std‐out.
	```

awk

	```
	-F fs
	--field-separator fs
		Use fs for the input field separator (the value of the FS predefined variable). 
	```

cut

	```
	-d, --delimiter=DELIM
		use DELIM instead of TAB for field delimiter

	-f, --fields=LIST
		select only these fields; also print any line that contains
		no delimiter character, unless the -s option is specified
	```

