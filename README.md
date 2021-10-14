# lisp-scripts
Some lisp scripts

## Connect with MariaDB

This script connect with MariaDB and save the query information in a CSV file.

### Simple Usage (one query ~ one sheet calc)

```lisp
(save-csv (query-sql "SELECT * FROM EXAMPLE LIMIT 10") "/home/lisper/first_10.csv")
```

Add que query and the filepath. The file save the information.


### Bulk usage (one query - massive sheet calc)

For Build a massive sheet calcs with one query, sheets with a specific number of rows.

```lisp
(bulk-csv "SELECT * FROM example WHERE fecha BETWEEN '1966-08-30' AND '1976-08-30'" 0 500 "/home/lisper/output-sheets")
```

#### Bulk-csv parameters.

```lisp
(bulk-csv query from to directory-filepath)
```

* from: query from 0 or any row?

* to: define the rows by file

* directory-filepath: Output path


This command get all the information of the query, but build files with 500 rows and save with the continue names from 0 to the end.

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