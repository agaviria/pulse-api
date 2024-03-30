#!/bin/bash
set -e

# The following bash script is required, because this repo pulls a postgres extension to create Ulid ID's.
# Therefore we prepare the database with a new user and database to simplify migrations use via SQLx.
# Be sure to change db_user, db_password, cluster_name, db_name to your configuration needs and rename this
# file ./init-db.sh

echo "************ START DATABASE UPGRADE ************"

# Ensure correct ownership and permissions of the data directory
mkdir -p /var/lib/postgresql/data
chown -R postgres:postgres /var/lib/postgresql/data

# Initialize a new PostgreSQL database if not exists
if [ ! -f /var/lib/postgresql/data/PG_VERSION ]; then
    su - postgres -c "/usr/local/pgsql/bin/initdb -D /var/lib/postgresql/data"
fi

# Check if PostgreSQL server is already running
if [ -f /var/lib/postgresql/data/postmaster.pid ]; then
    echo "PostgreSQL server is already running."
else
    # Start the PostgreSQL server
    su - postgres -c "/usr/local/pgsql/bin/pg_ctl -D /var/lib/postgresql/data -l logfile start"
fi

# Check if a PostgreSQL cluster is already started
if pg_isready -h /var/run/postgresql >/dev/null; then
    echo "PostgreSQL cluster 'foocluster' is already started."
else
    # Create a new PostgreSQL cluster with postgres version -> 16 and cluster name "foocluster" 
    pg_createcluster --start 16 foocluster
fi

echo "************* END DATABASE UPGRADE *************"

echo "*********** START CREATE USER AND DB ***********"

# Check if the superuser "postgres" exists
if psql -U postgres -tc "SELECT 1 FROM pg_user WHERE usename = 'postgres'" | grep -q 1; then
    echo "Superuser 'postgres' exists. Continuing..."
else
    echo "Superuser 'postgres' does not exist. Exiting..."
    exit 1
fi

# Create `webmaster` user if not exists
psql -U postgres -tc "SELECT 1 FROM pg_user WHERE usename = 'bar'" | grep -q 1 || psql -U postgres -c "CREATE USER bar WITH ENCRYPTED PASSWORD 'fake_password';"

# Create the app database if not exists
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'some_db_name'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE some_db_name;"
psql -U postgres -c "ALTER DATABASE some_db_name OWNER TO bar;"

echo "************ END CREATE USER AND DB ************"
