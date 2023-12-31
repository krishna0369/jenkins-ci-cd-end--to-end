FROM tomcat:8.0.20-jre8

COPY target/krishna-app*.war /usr/local/tomcat/webapps/krishna-app.war
