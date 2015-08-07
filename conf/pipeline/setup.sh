#!/bin/bash
# ---------------------------------------------------------------------------
# Setup processing for
#
# Environment Variable Prequisites
#
#   JAVA_HOME       Directory of Java Version
#
#
# $Id: setup.sh,v 1.1 2008/11/13 16:23:07 mohanar Exp $
# ---------------------------------------------------------------------------

echo

if [ "$#" -lt "2" ]; then
  echo "Missing required command line arguments"
  echo "USAGE: $0 <admin email id> <SMTP server> <xnat url>"
  exit 1
fi


echo " "
echo "Using JAVA_HOME:         $JAVA_HOME"
echo " "
echo "Verify Java Version (with java -version)"
java -version

#======================================================================================================
# WORK_DIR gotten from http://software-lgl.blogspot.com/2009/03/find-full-path-of-your-bash-script.html
#======================================================================================================
WORK_DIR=`dirname "$(cd ${0%/*} && echo $PWD/${0##*/})"`

if [ -z $WORK_DIR ]; then
	WORK_DIR=`pwd`
fi

MAVEN_HOME="$WORK_DIR"/maven-1.0.2

if [ ! -d  $MAVEN_HOME ];  then
  WORK_DIR="$WORK_DIR"/pipeline
fi

MAVEN_HOME="$WORK_DIR"/maven-1.0.2

echo $WORK_DIR
echo $MAVEN_HOME

# chmod +x "$MAVEN_HOME"/bin/maven

"$MAVEN_HOME"/bin/maven -d $WORK_DIR -Dadmin.email=$1 -Dsmtp.server=$2 -Dxnat.url=$3 pipeline:setup

exit $status
