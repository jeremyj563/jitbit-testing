#!/bin/bash

# start SQL Server, run the script to create the DB schema, run the app
/usr/local/bin/init-db.sh & /opt/mssql/bin/sqlservr & cd /var/www/helpdesk && dotnet HelpDesk.dll