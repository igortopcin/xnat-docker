############################################################
# Dockerfile that builds a new XNAT image from source
############################################################

# Set the base image to ubuntu
FROM ubuntu:trusty

# Update the sources list and install base packages
RUN apt-get update && apt-get install -y tar less git curl vim wget unzip \
	netcat software-properties-common mercurial unzip postgresql-client-9.3 && \
	apt-get purge -y openjdk*

# Install JDK HotSpot
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	add-apt-repository ppa:webupd8team/java && \
	apt-get update && \
	apt-get install -y oracle-java7-installer

ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

ENV XNAT_HOME /usr/local/xnat

# Install Tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV TOMCAT_HOME $CATALINA_HOME
ENV PATH $XNAT_HOME/bin:$CATALINA_HOME/bin:$PATH

RUN mkdir -p $CATALINA_HOME
WORKDIR $CATALINA_HOME

ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.63
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*

# BUILD APPLICATION
RUN mkdir -p $XNAT_HOME
WORKDIR $XNAT_HOME

ENV XNAT xnat-1.6.4
ENV XNAT_TGZ_URL ftp://ftp.nrg.wustl.edu/pub/xnat/${XNAT}.tar.gz

# Download xnat
RUN curl --keepalive-time 60 -O "$XNAT_TGZ_URL.md5" -O "$XNAT_TGZ_URL"

RUN md5sum -c $XNAT.tar.gz.md5 && \
	tar -zxvf $XNAT.tar.gz --strip-components=1 && \
	rm $XNAT.tar.gz*

RUN find . -name "*.sh" -type f -exec chmod 777 {} + && \
	find . -name "bin" -type d -exec chmod -R 777 {} +

# Create XNAT library dirs
ENV XNAT_LIBRARY_DIR /opt/data
VOLUME $XNAT_LIBRARY_DIR

# Run setup (may need to run ./bin/update.sh if it fails)
ADD conf/build.properties build.properties
ADD conf/project.properties project.properties
ADD conf/maven.xml maven.xml

RUN ./bin/setup.sh

# Replace every maven repository reference with xnat's repository address
RUN find . -type f -exec sed -i -- 's/http:\/\/repo1.maven.org\/maven/http:\/\/maven.xnat.org\/xnat-maven1,http:\/\/repo1.maven.org\/maven/g' {} +
RUN ./bin/maven.sh xdat:deployWebapp

# Add utility scripts for bootstrapping the application
ADD scripts ./bin

# Startup procedure
WORKDIR $CATALINA_HOME

EXPOSE 8080

ENV CATALINA_OPTS -Xmx2G -Xms2G -XX:MaxPermSize=256m
ENV SITE_URL "http:\/\/localhost:8080\/xnat"

CMD ["run-xnat.sh"]
