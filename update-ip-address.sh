#!/bin/bash

if [[ $# -eq 0 ]]
  then
    echo "Must provide domain name to be updated"
    exit 1
fi

# Read Credentials
credentials=$(<$1)

# Update IP address
echo "Updating IP Address for $2 - $(date)" >> $2.log
curl --head --user $credentials https://ydns.io/api/v1/update/?host=$2 >> $2.log

# Trim log file
echo "$(tail -n 5000 $2.log)" > $2.log
