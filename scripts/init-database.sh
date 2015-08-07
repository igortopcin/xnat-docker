#! /bin/bash
cd $XNAT_HOME/deployments/xnat

DB_HOST=${DB_HOST:-"postgres"}
DB_NAME=${DB_NAME:-"xnat"}
DB_USER=${DB_USER:-"xnat"}
DB_PASSWORD=${DB_PASSWORD:-"calvin"}

# Create database schema
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -d $DB_NAME -f sql/xnat.sql -U $DB_USER

# Bootstrap security settings (and create an admin user for initial setup of the application)
StoreXML -l security/security.xml -allowDataDeletion true

# Create additional variable sets which can be used by particular projects in XNAT to customize the options for subject demographics. This step is optional.
StoreXML -dir ./work/field_groups -u admin -p admin -allowDataDeletion true

cd -
