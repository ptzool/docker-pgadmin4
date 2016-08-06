# PGAdmin4 Docker

 * `PGADMIN_USER` for user name (default value is `admin@pgadmin.org`)
 * `PGADMIN_PASSWORD` for password (default value is `pgadmin`)

#### EXAMPLE
 ```
 docker run -v ~/pgadmin4/data:/home/pgadmin/.pgadmin -P -e PGADMIN_USER=test@test.com -e PGADMIN_PASSWORD=123456 docker pull atkinschang/pgadmin4
 ```
