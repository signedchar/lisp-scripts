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

(defparameter *database-name* "example")
(defparameter *username* "lisper")
(defparameter *userpasswd* "password")

(defun query-sql (query)
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
  "Making the CSV file, util for visualization with calc sheets."
  (with-open-file (out-stream output-filepath
			      :direction :output
			      :if-does-not-exist :create
			      :if-exists :append)
    (mapcar #'(lambda (str)
		(write-line str out-stream))
	    (list-to-csv-line output-query))))
