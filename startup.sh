#!/usr/bin/env bash

service virtuoso-opensource-7 start &&
echo "USER_GRANT_ROLE('SPARQL', 'SPARQL_UPDATE');" | isql-vt &&
su ubuntu -c "cd /opt/synbiohub && forever ./synbiohub.js"



