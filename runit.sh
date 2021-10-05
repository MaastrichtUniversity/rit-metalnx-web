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


echo "Deploying war file..."
mkdir $CATALINA_HOME/webapps/metalnx && \
  cd $CATALINA_HOME/webapps/metalnx && \
  jar -xf $CATALINA_HOME/webapps/metalnx.war && \
#  ls -l $CATALINA_HOME/webapps/metalnx && \
  rm $CATALINA_HOME/webapps/metalnx.war && \
  cd $CATALINA_HOME/

echo "Reconfiguring log level..."
cp /tmp/log4j.properties /usr/local/tomcat/webapps/metalnx/WEB-INF/classes/log4j.properties

# Start tomcat
echo "Starting Metalnx"
catalina.sh start

# End with a persistent foreground process
tail -f /usr/local/tomcat/logs/catalina.out
