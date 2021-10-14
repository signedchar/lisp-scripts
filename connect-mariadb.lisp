;; OS Debian Bullseye (11)
;; Previously install default-libmysqlclient-dev
;;
;; Create an user in mariadb
;; mysql -u root
;; CREATE DATABASE example;
;; CREATE USER 'lisper'@localhost IDENTIFIED BY 'password';
;; GRANT ALL PRIVILEGES ON *.* TO 'lisper'@localhost IDENTIFIED BY 'password';
;; GRANT ALL PRIVILEGES ON example.* TO 'lisper'@localhost
;; FLUSH PRIVILEGES;

(ql:quickload '(dbi cffi cl-fad))
(push "/usr/lib/x86_64-linux-gnu/" cffi:*foreign-library-directories*)
(cffi:load-foreign-library "libmariadbclient.so"
			   :search-path "/usr/lib/x86_64-linux-gnu/")

(defparameter *database-name* "example")
(defparameter *username* "lisper")
(defparameter *userpasswd* "lisper")

(defun query-sql (query)
  "Send a query to MariaDB."
  (dbi:with-connection
      (conn :mysql :database-name *database-name*
		   :username *username*
		   :password *userpasswd*)
    (let* ((qr (dbi:prepare conn query))
	   (output-query (dbi:execute qr)))
      (dbi:fetch-all output-query))))

(defun clean-symbols (output-query)
  "Remove the symbols of the query."
  (mapcar #'(lambda (list)
	      (remove-if #'symbolp list))
	  output-query))

(defun list-to-string (list)
  "Transform a list to an string."
  (format nil "~{~A~}" list))

(defun list-to-csv-line (output-query)
  "The form of `output-query' is a list of list. *data*"
  (mapcar #'(lambda (lst)
	      (list-to-string
	       (alexandria:flatten
		(mapcar #'(lambda (elem)
			    (list elem ";"))
			lst))))
	  (clean-symbols output-query)))

(defun save-csv (output-query output-filepath)
  "Save the query returns in a CSV file or in a sheet calc."
  (with-open-file (out-stream output-filepath
			      :direction :output
			      :if-does-not-exist :create
			      :if-exists :append)
    (mapcar #'(lambda (str)
		(write-line str out-stream))
	    (list-to-csv-line output-query))))

(defmacro cct (&rest strings)
  "For abstract concatenate strings."
  `(concatenate 'string ,@strings))

(defun query-interval (query start limit)
  "Return a list with a new query and the interval of consult."
  (list
   (cct query " " "LIMIT " (write-to-string start) "," (write-to-string limit))
   (+ start limit)))

(defun last-char (string)
  "Return the last character of a string."
  (char string (- (length string) 1)))

(defun last-slash? (string)
  "Return T if the last character is a slash '/' else
return false."
  (if (equal #\/ (last-char string))
      t
      nil))

(defun append-slash (string)
  "If the `string' have a character slash, return `string', else
return a `string' with character slash."
  (if (last-slash? string)
      string
      (cct string "/")))

(defun filename (directory-path filename)
  "Return a complete path if `directory-path' exists, else
return false."
  (and
   (cl-fad:directory-exists-p directory-path)
   (cct (append-slash directory-path) (write-to-string filename))))

(defun bulk-csv (query start limit directory-path)
  "Build a pool of CSV or sheets calc from a query, the limit of rows for
each sheet is the `limit' variable."
  (let* ((new-query (query-interval query start limit))
	 (new-filename (filename directory-path (cadr new-query))))
    (if (equal nil (funcall #'save-csv (query-sql (car new-query)) new-filename))
	nil
	(bulk-csv query (+ start limit) limit directory-path))))
