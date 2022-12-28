# homeiot-api-quarkus

## Build prerequisites

Before building, install the following software.
- docker
- docker-compose
- OpenJDK 11
- Maven

After installing the software, execute the following command.
```
$ mvn wrapper:wrapper

## Prepare the environment config file

```
$ vi .env
```

- DB_USER=<database user name to access>
- DB_PWD=<database user's password to access>
- DB_INSIDE_PORT=<database port number to access from the api server>
- DB_OUTSIDE_PORT=<database port number to access from the outside of the container>
- API_PORT=<API server's port number to access>

## Build

```
$ ./mvnw package
```

## Run the servers

```
$ docker-compose up -d
```

To test the connection from a client, try the following URL via your browser.
```
http://<Server's IP address or the FQDN>:<API_PORT>/q/swagger-ui
```
