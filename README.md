# XNAT Docker Image

## Setting up the database
Create a new user for XNAT in your postgres:
```shell
su postgres

createuser -P xnat
#choose a password for xnat user and then retype it.

createdb -O xnat xnat
```

## Bootstrap the application
Run the following command to bootstrap XNAT. The following command will create the necessary tables and setup initial user data.

```shell
docker run --name xnat --link postgres -e DB_HOST=postgres -e DB_PASSWORD=calvin xnat init-database.sh
```

## Run XNAT

Example with postgres running within the same host, using boot2docker:
```shell
docker run -d --name xnat --link postgres -p 8080:8080 -p 8104:8104 -e SITE_URL="http:\/\/192.168.59.103:8080\/xnat" -e DB_PASSWORD=calvin xnat
```

Example with postgres running somewhere else:
```shell
docker run -d --name xnat --add-host postgres:10.8.0.26 -p 8080:8080 -p 8104:8104 -e SITE_URL="http:\/\/192.168.59.103:8080\/xnat" -e DB_PASSWORD=calvin xnat
```
