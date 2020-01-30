sudo cat /etc/httpd/logs/access_log | grep -E '.*\[' | sed -E 's/\W* \W* /,/g' | sed -E 's/] /],/g' | sed -E 's/\" /",/g' | sed -E 's/(,\w{3}) .*/\1 /' > log.csv
