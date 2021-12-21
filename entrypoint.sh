#!/bin/bash

# run the script to create the DB schema, start MSSQL, run the app
/usr/local/bin/init-db.sh & /opt/mssql/bin/sqlservr & cd /var/www/helpdesk && dotnet HelpDesk.dll