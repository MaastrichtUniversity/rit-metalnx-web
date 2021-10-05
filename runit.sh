#!/bin/sh -e

if [ -f /tmp/cert/server.crt ];
then
   echo "Cert will be imported"
   set +e
   keytool -delete -noprompt -alias mycert -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit
   set -e
   keytool -import -trustcacerts -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit -noprompt -alias mycert -file /tmp/cert/server.crt
else
   echo "No cert to import"
fi


# Deploy war file by starting tomcat
echo "Deploying war file..."
catalina.sh start && sleep 15

# Overwrite default logging properties
echo "Reconfiguring log level..."
cp /tmp/log4j.properties /usr/local/tomcat/webapps/metalnx/WEB-INF/classes/log4j.properties

# Restart tomcat
echo "Starting Metalnx"
catalina.sh stop && sleep 5 && catalina.sh start

# End with a persistent foreground process
tail -f /usr/local/tomcat/logs/catalina.out