FROM debian:buster
LABEL maintainer=contact@jodionne.com

ARG TOMCAT_VERSION 

# Install Dependencies
RUN apt-get update && \
    apt-get install -y apt-utils curl wget unzip default-mysql-client default-jdk

# Install Tomcat and copy related files
RUN mkdir /opt/tomcat/
WORKDIR /opt/tomcat
RUN TOMCAT_MAJOR_VERSION=$(echo "${TOMCAT_VERSION}" | cut -d '.' -f 1) && \
    curl -O https://muug.ca/mirror/apache-dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xvfz apache*.tar.gz && \
    mv apache-tomcat-${TOMCAT_VERSION}/* /opt/tomcat/.

WORKDIR /opt/tomcat/webapps
RUN find ./ -mindepth 1 ! -regex '^./manager\(/.*\)?' -delete

COPY tomcat/ /opt/tomcat/

ENV CATALINA_HOME /opt/tomcat

# Copy binaries and install IdentityIQ
COPY binaries /tmp/binaries
RUN \
    # Apply base solution
    unzip /tmp/binaries/base/identityiq-*.zip identityiq.war && \
    unzip identityiq.war -d identityiq && \
    rm identityiq.war && \
    \
    # Apply patch (if provided)
    for FILE in /tmp/binaries/patch/identityiq-*.jar; \
    do unzip -o ${FILE} -d identityiq 2> /dev/null || true; \
    done && \
    \
    # Apply efixes (if provided)
    for FILE in /tmp/binaries/efixes/*.zip; \
    do unzip -o ${FILE} -d identityiq 2> /dev/null || true; \
    done && \
    \
    # Make iiq console executable
    chmod +x identityiq/WEB-INF/bin/iiq

# Port to access Tomcat
EXPOSE 8080

# Prepare entrypoint to execute adjust database and to start tomcat
COPY scripts/ /scripts/
RUN chmod +x /**/*.sh
ENTRYPOINT /scripts/entrypoint.sh