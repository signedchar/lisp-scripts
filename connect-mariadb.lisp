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

(ql:quickload '(dbi cffi))
(push "/usr/lib/x86_64-linux-gnu/" cffi:*foreign-library-directories*)
(cffi:load-foreign-library "libmariadbclient.so"
			   :search-path "/usr/lib/x86_64-linux-gnu")

;; connection with database and show the first 10 rows.
(defparameter *data* (dbi:with-connection
			 (connection :mysql :database-name "example"
					    :username "lisper" :password "password")
		       (let* ((query (dbi:prepare connection "select * from example limit 10"))
			      (output (dbi:execute query)))
			 (dbi:fetch-all output))))

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

(defun write-line-in-a-file (output-query output-filepath)
  (with-open-file (out-stream output-filepath
			  :direction :output
			  :if-does-not-exist :create
			  :if-exists :append)
    (mapcar #'(lambda (str)
		(write-line str out-stream))
	    (list-to-csv-line output-query))))
