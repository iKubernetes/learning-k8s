#FROM tomcat:9.0-jdk17-openjdk-slim
FROM tomcat:10.1-jdk17-temurin-jammy

ADD ./sources.list /etc/apt/sources.list

#ENV TOMCAT_SIMPLECLIENT_VERSION=0.12.0
#ENV TOMCAT_EXPORTER_VERSION=0.0.15
#
#RUN apt-get update && apt-get install -y curl && \
#    curl -v --fail --location https://search.maven.org/remotecontent?filepath=io/prometheus/simpleclient/${TOMCAT_SIMPLECLIENT_VERSION}/simpleclient-${TOMCAT_SIMPLECLIENT_VERSION}.jar --output /usr/local/tomcat/lib/simpleclient-${TOMCAT_SIMPLECLIENT_VERSION}.jar && \
#    curl -v --fail --location https://search.maven.org/remotecontent?filepath=io/prometheus/simpleclient_common/${TOMCAT_SIMPLECLIENT_VERSION}/simpleclient_common-${TOMCAT_SIMPLECLIENT_VERSION}.jar --output /usr/local/tomcat/lib/simpleclient_common-${TOMCAT_SIMPLECLIENT_VERSION}.jar && \
#    curl -v --fail --location https://search.maven.org/remotecontent?filepath=io/prometheus/simpleclient_hotspot/${TOMCAT_SIMPLECLIENT_VERSION}/simpleclient_hotspot-${TOMCAT_SIMPLECLIENT_VERSION}.jar --output /usr/local/tomcat/lib/simpleclient_hotspot-${TOMCAT_SIMPLECLIENT_VERSION}.jar && \
#    curl -v --fail --location https://search.maven.org/remotecontent?filepath=io/prometheus/simpleclient_servlet/${TOMCAT_SIMPLECLIENT_VERSION}/simpleclient_servlet-${TOMCAT_SIMPLECLIENT_VERSION}.jar --output /usr/local/tomcat/lib/simpleclient_servlet-${TOMCAT_SIMPLECLIENT_VERSION}.jar && \
#    curl -v --fail --location https://search.maven.org/remotecontent?filepath=io/prometheus/simpleclient_servlet_common/${TOMCAT_SIMPLECLIENT_VERSION}/simpleclient_servlet_common-${TOMCAT_SIMPLECLIENT_VERSION}.jar --output /usr/local/tomcat/lib/simpleclient_servlet_common-${TOMCAT_SIMPLECLIENT_VERSION}.jar && \
#    curl -v --fail --location https://search.maven.org/remotecontent?filepath=nl/nlighten/tomcat_exporter_client/${TOMCAT_EXPORTER_VERSION}/tomcat_exporter_client-${TOMCAT_EXPORTER_VERSION}.jar --output /usr/local/tomcat/lib/tomcat_exporter_client-${TOMCAT_EXPORTER_VERSION}.jar && \
#    curl -v --fail --location https://search.maven.org/remotecontent?filepath=nl/nlighten/tomcat_exporter_servlet/${TOMCAT_EXPORTER_VERSION}/tomcat_exporter_servlet-${TOMCAT_EXPORTER_VERSION}.war --output /usr/local/tomcat/webapps/metrics.war

RUN mv /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps/
ADD ./manager-context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
ADD ./docs-context.xml /usr/local/tomcat/webapps/docs/META-INF/context.xml
ADD ./examples-context.xml /usr/local/tomcat/webapps/examples/META-INF/context.xml
