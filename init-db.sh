#!/bin/bash

# wait for process 'sqlservr' to start
until pids=$(pidof sqlservr)
do
  sleep 3
done

# check if database 'JitbitHelpDesk' already exists
/opt/mssql-tools/bin/sqlcmd \
  -S $JITBIT_DB_HOST \
  -U $JITBIT_DB_USER \
  -P $JITBIT_DB_PASS \
  -Q "IF DB_ID('JitbitHelpDesk') IS NULL THROW 51000, '', 1;" \
  -b \
  > /dev/null

JITBIT_DB_MISSING=$?

if [[ $JITBIT_DB_MISSING == 1 ]]; then
  # database does not yet exist, so create it
  /opt/mssql-tools/bin/sqlcmd \
    -S $JITBIT_DB_HOST \
    -U $JITBIT_DB_USER \
    -P $JITBIT_DB_PASS \
    -Q "CREATE DATABASE JitbitHelpDesk"

  # and create all tables
  /opt/mssql-tools/bin/sqlcmd \
    -S $JITBIT_DB_HOST \
    -U $JITBIT_DB_USER \
    -P $JITBIT_DB_PASS \
    -i $JITBIT_HD_PATH/sql/CreateTables.sql
fi
