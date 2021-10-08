# lisp-scripts
Some lisp scripts

## Connect with MariaDB

This script connect with MariaDB and save the query information in a CSV file.

### Usage

```lisp
(save-csv (query-sql "SELECT * FROM EXAMPLE LIMIT 10") "/home/lisper/first_10.csv")
```

Add que query and the filepath. The file save the information.
