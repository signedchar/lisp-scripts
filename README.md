# lisp-scripts
Some lisp scripts

## Connect with MariaDB

This script connect with MariaDB and save the query information in a CSV or spreadsheet file.

### Simple Usage (one query ~ one spreadsheet)

```lisp
(save-csv (query-sql "SELECT * FROM EXAMPLE LIMIT 10") "/home/lisper/first_10.csv")
```

Add que query and the filepath. The file save the information.


### Bulk usage (one query - massive spreadsheet)

For Build a massive spreadsheets with one query, sheets with a specific number of rows.

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

### Example for MariaDB user configuration

* Operating System configuration:

```bash
$> cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"

(root)> apt install default-libmysqlclient-dev
```

* MariaDB configuration:

```bash
$> mysql -u root
MariaDB > CREATE DATABASE example;
MariaDB > CREATE USER 'your_user'@localhost IDENTIFIED BY 'your_password';
MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'your_user'@localhost IDENTIFIED BY 'your_password';
MariaDB > GRANT ALL PRIVILEGES ON example.* TO 'your_user'@localhost;
MariaDB > FLUSH PRIVILEGES;
```