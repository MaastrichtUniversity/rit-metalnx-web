# rit-metalnx-web
Metalnx is a GUI for iRODS that runs on a tomcat web server. It was originally developed by EMC-Dell (versions < 1.1.1)
and further development and maintenance was taken over by [irods-contrib](https://github.com/irods-contrib/metalnx-web) in 2017.

## Run instructions for docker-compose
First, create an `.env` file in the root of your workdir, based on this example:
```
ENV_METALNX_VERSION=2.5.0
ENV_METALNX_POSTGRES_VERSION=11
```

Then add a `docker-compose.yml` file based on this example:
```
version: '2'
services:
  metalnx:
    image: irods/metalnx:${ENV_METALNX_VERSION}
    hostname: metalnx
    volumes:
      - ./metalnx-configuration/metalnxConfig.xml:/etc/irods-ext/metalnxConfig.xml
      - ./metalnx-configuration/metalnx.properties:/tmp/metalnx.properties
      - ./log4j.properties:/tmp/log4j.properties
      - ./runit.sh:/runit.sh

    environment:
      IRODS_HOST: irods.dh.local
      IRODS_PORT: 1247
      IRODS_ZONE: nlmumc
      IRODS_USER: rods
      IRODS_PASS: irods
      METALNX_DB_URL: "jdbc:postgresql://metalnx-db.dh.local:5432/metalnxdb"
      METALNX_DB_USER: metalnxuser
      METALNX_DB_PASS: foobar
  metalnx-db:
    image: postgres:${ENV_METALNX_POSTGRES_VERSION}
    hostname: metalnx-db
    environment:
      POSTGRES_PASSWORD: foobar
      POSTGRES_USER: metalnxuser
      POSTGRES_DB: metalnxdb
```

More settings can tweaked in the `./metalnx-configuration/metalnx.properties` file. Please note that all the settings 
indicated with `PLACEHOLDER` will be overridden by the environment values from `docker-compose.yml`.

Finally, build and run the container
```
docker-compose build metalnx
docker-compose up -d metalnx
```

### iRODS SSL/TLS
Configure the client-side SSL setting by editing the `./metalnx-configuration/metalnx.properties` file.

When connecting to iRODS servers that have SSL **disabled**:
```
    ssl.negotiation.policy=CS_NEG_REFUSE
```

When connecting to iRODS servers that have SSL **enabled**:
```
    ssl.negotiation.policy=CS_NEG_REQUIRE
```

Or, when you don't want to enforce this on the client side and just connect to whatever the server is offering, use:
```
    ssl.negotiation.policy=CS_NEG_DONT_CARE
```

### iRODS SSL/TLS with self-signed certificates
If you're using certificates that are signed by your own CA (and thus not trusted by default), you can enable this trust
by volume binding your root certificate to the Metalnx container. 
1. Edit the `docker-compose.yml` and add this line to `volumes:`
    ```
      metalnx:
      (...)
        volumes:
          - ./path/to/root/cert.pem:/tmp/cert/server.crt
      (...)
    ```
1. Restart the docker container and the `runit.sh` script will do the rest.
    ```
    docker-compose up -d --force-recreate metalnx
    ```

