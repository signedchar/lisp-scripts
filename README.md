# lisp-scripts
Some lisp scripts

## Connect with MariaDB

This script connect with MariaDB and save the query information in a CSV file.

### Usage

```lisp
(save-csv (query-sql "SELECT * FROM EXAMPLE LIMIT 10") "/home/lisper/first_10.csv")
```

Add que query and the filepath. The file save the information.

### Troubleshooting

If you send a query, ex:

```lisp
(query-sql "SELECT * FROM EXAMPLE LIMIT 10")
```

And return this error:

```
Illegal UTF-8 Character starting at position ...
```

Add this information in "/etc/mysql/mariadb.cnf"

```
[mysqld]
character-set-client-handshake = FALSE
collation-server = utf8mb4_unicode_ci
init-connect='SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci'
character-set-server = utf8mb4
```


Restart the service and send again the test:

```
(query-sql "SELECT * FROM EXAMPLE LIMIT 10")
```