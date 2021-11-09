FROM tomcat
RUN rm -fr /usr/local/tomcat/webapps/ROOT
COPY target/devops.mavenproj1.war /usr/local/tomcat/webapps/ROOT.war
