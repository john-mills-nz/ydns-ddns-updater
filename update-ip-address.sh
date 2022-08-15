#!/bin/bash

failed=0

# Check arguments
if [[ $# -lt 2 ]]
  then
    echo -e "Must provide a credentials file path and one or more domain names to be updated\nusage: ./update-ip-address.sh credentials-file domain-name-1 [domain-name-2 domain-name-3 ...]"
    exit 1
fi

# Read Credentials
credentials=$(<$1)

# Update IP addresses
shift
for domainName in "$@"
do
  echo "Updating IP Address for $domainName - $(date)" >> $domainName.log
  
  for ((retryCounter=0; retryCounter<=5; retryCounter++ ))
  do
    result=$(curl --user $credentials --silent --show-error --max-time 10 --write-out ":::%{http_code}" https://ydns.io/api/v1/update/?host=$domainName)
    statusCode=${result##*\:::}
    message=${result%%\:::*}
    
    if [[ statusCode -eq 200 ]]
      then
        break
    fi
    
    sleep $((retryCounter * retryCounter))
    
  done
  
  echo -e "Status: ${statusCode}\nResponse: ${message}\nRetries: ${retryCounter}\n" >> $domainName.log
 
  # Trim log file
  echo "$(tail -n 5000 $domainName.log)" > $domainName.log
  
  if [[ statusCode -ge 400 ]]
    then
      failed=1
      failureStatusCode=statusCode
      failureMessage=message
  fi
  
done

# Report failure if necessary
if [[ failed -eq 1 ]]
  then
    echo -e "${failureStatusCode} - ${failureMessage}"
    exit 1
fi