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
  rm $CATALINA_HOME/webapps/metalnx.war && \
  cd $CATALINA_HOME/

echo "Reconfiguring log level..."
cp /tmp/log4j.properties /usr/local/tomcat/webapps/metalnx/WEB-INF/classes/log4j.properties

echo "Reconfiguring Metalnx properties file..."
env_file=/etc/irods-ext/metalnx.properties
cp /tmp/metalnx.properties $env_file
sed -ir "s|irods.host=.*$|irods.host=$IRODS_HOST|" $env_file
sed -ir "s|irods.port=.*$|irods.port=$IRODS_PORT|" $env_file
sed -ir "s|irods.zoneName=.*$|irods.zoneName=$IRODS_ZONE|" $env_file
sed -ir "s|irods.admin.user=.*$|irods.admin.user=$IRODS_USER|" $env_file
sed -ir "s|irods.admin.password=.*$|irods.admin.password=$IRODS_PASS|" $env_file
sed -ir "s|jobs.irods.username=.*$|jobs.irods.username=$IRODS_USER|" $env_file
sed -ir "s|jobs.irods.password=.*$|jobs.irods.password=$IRODS_PASS|" $env_file
sed -ir "s|db.url=.*$|db.url=$METALNX_DB_URL|" $env_file
sed -ir "s|db.username=.*$|db.username=$METALNX_DB_USER|" $env_file
sed -ir "s|db.password=.*$|db.password=$METALNX_DB_PASS|" $env_file

# Start tomcat
echo "Starting Metalnx"
catalina.sh start

# End with a persistent foreground process
tail -f /usr/local/tomcat/logs/catalina.out
