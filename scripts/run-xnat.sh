#!/bin/bash
# Replaces xnat home with $SITE_URL
find $CATALINA_HOME/webapps/xnat -type f -exec sed -i -- "s/http:\/\/localhost:8080\/xnat/$SITE_URL/g" {} +
find $XNAT_HOME -type f -exec sed -i -- "s/http:\/\/localhost:8080\/xnat/$SITE_URL/g" {} +

exec catalina.sh run
