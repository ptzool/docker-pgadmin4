#!/bin/bash
set -e

on_error() {
  echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
  exit $2
}

if [ "$1" == "/usr/bin/python" ]; then
    chmod 700 /home/pgadmin/.pgadmin
    chown -R pgadmin /home/pgadmin/.pgadmin
    if [ ! -s "/home/pgadmin/.pgadmin/config_local.py" ]; then
        gosu pgadmin touch /home/pgadmin/.pgadmin/config_local.py
    fi

    if [ ! -s "/home/pgadmin/.pgadmin/pgadmin4.db" ]; then
        gosu pgadmin expect -c "spawn /usr/bin/python /usr/local/lib/python2.7/dist-packages/pgadmin4/setup.py;expect \"Email address:\";send \"$PGADMIN_USER\n\";expect \"Password:\";send \"$PGADMIN_PASSWORD\n\";expect \"Retype password:\";send \"$PGADMIN_PASSWORD\n\";expect eof;exit"
    fi
    exec gosu pgadmin "$@"
fi

exec "$@"