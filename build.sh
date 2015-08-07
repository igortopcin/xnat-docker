#!/bin/bash
# BUILD APPLICATION
# Requirements: Java > 1.7 and JAVA_HOME environment variable
XNAT_HOME=`pwd`/.xnat
XNAT=xnat-1.6.4
XNAT_TGZ_URL=ftp://ftp.nrg.wustl.edu/pub/xnat/${XNAT}.tar.gz
XNAT_DEPLOY_DIR=`pwd`/.deploy

mkdir -p $XNAT_HOME && \
cd $XNAT_HOME && \

# Download xnat
curl --keepalive-time 60 -O "$XNAT_TGZ_URL.md5" -O "$XNAT_TGZ_URL" && \

md5sum -c $XNAT.tar.gz.md5 && \
tar -zxf $XNAT.tar.gz --strip-components=1 && \
rm $XNAT.tar.gz* && \

find . -name "*.sh" -type f -exec chmod 777 {} + && \
find . -name "bin" -type d -exec chmod -R 777 {} + && \

# Run setup
cp ../conf/build.properties . && \
cp ../conf/project.properties . && \
cp ../conf/maven.xml . && \

./bin/setup.sh && \

# Replace every maven repository reference with xnat's repository address
# In macOS, set LC_CTYPE=C && LANG=C, otherwise you may get 'illegal byte sequence' error
find . -type f -exec sed -i -- 's/http:\/\/repo1.maven.org\/maven/http:\/\/maven.xnat.org\/xnat-maven1,http:\/\/repo1.maven.org\/maven/g' {} + && \
./bin/maven.sh xdat:deployWebapp -Dmaven.appserver.home=$XNAT_DEPLOY_DIR
