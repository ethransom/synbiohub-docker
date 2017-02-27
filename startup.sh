#!/usr/bin/env bash

copy_default() {
    if [ ! -f $1 ]; then
        echo Copying default file: $1
        cp -f /opt/defaults$1 $1
    fi
}

copy_default /mnt/config/config.local.json
copy_default /mnt/config/virtuoso.ini

service virtuoso-opensource-7 start &&
echo "USER_GRANT_ROLE('SPARQL', 'SPARQL_UPDATE');" | isql-vt &&
su ubuntu -c "cd /opt/synbiohub && forever ./synbiohub.js"



