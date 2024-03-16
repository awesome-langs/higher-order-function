(defun p_e_escape-string (s)
    (let ((p_e_escape-char (lambda (c)
            (cond
                ((char= c #\Newline) "\\n")
                ((char= c #\Return) "\\r")
                ((char= c #\Tab) "\\t")
                ((char= c #\\) "\\\\")
                ((char= c #\") "\\\"")
                (t (string c))))))
        (format nil "~{~A~}" (mapcar p_e_escape-char (coerce s 'list)))))

(defun p_e_bool ()
    (lambda (b)
    (when (not (or (eq b t) (eq b nil))) (error "IllegalArgumentException"))
    (if b "true" "false")))

(defun p_e_int ()
    (lambda (i)
    (when (not (integerp i)) (error "IllegalArgumentException"))
    (write-to-string i)))

(defun p_e_double ()
    (lambda (d)
    (when (not (floatp d)) (error "IllegalArgumentException"))
    (format nil "~,6f" d)))

(defun p_e_string ()
    (lambda (s)
    (when (not (stringp s)) (error "IllegalArgumentException"))
    (concatenate 'string "\"" (p_e_escape-string s) "\"")))

(defun p_e_list (f0)
    (lambda (lst)
        (when (not (listp lst)) (error "IllegalArgumentException"))
        (concatenate 'string "[" (format nil "~{~A~^, ~}" (mapcar f0 lst)) "]")))

(defun p_e_ulist (f0)
    (lambda (lst)
        (when (not (listp lst)) (error "IllegalArgumentException"))
        (concatenate 'string "[" (format nil "~{~A~^, ~}" (sort (mapcar f0 lst) #'string<)) "]")))

(defun p_e_idict (f0)
    (let ((f1 (lambda (k v) (concatenate 'string (funcall (p_e_int) k) "=>" (funcall f0 v)))))
        (lambda (dct)
            (when (not (hash-table-p dct)) (error "IllegalArgumentException"))
            (let ((ret '()))
                (maphash (lambda (k v) (push (funcall f1 k v) ret)) dct)
                (concatenate 'string "{" (format nil "~{~A~^, ~}" (sort ret #'string<)) "}")))))

(defun p_e_sdict (f0)
    (let ((f1 (lambda (kv) (concatenate 'string (funcall (p_e_string) (car kv)) "=>" (funcall f0 (cdr kv))))))
        (lambda (dct)
            (when (not (hash-table-p dct)) (error "IllegalArgumentException"))
            (let ((ret '()))
                (maphash (lambda (k v) (push (funcall f1 (cons k v)) ret)) dct)
                (concatenate 'string "{" (format nil "~{~A~^, ~}" (sort ret #'string<)) "}")))))

(defun p_e_option (f0)
    (lambda (opt)
        (if opt (funcall f0 opt) "null")))

(defun p_e_create-dict (lst)
    (let ((ret (make-hash-table :test #'equal)))
        (dolist (kv lst)
            (setf (gethash (car kv) ret) (cdr kv)))
        ret))

(let ((p_e_out (format nil "~{~A~^~%~}"
                (list
                    (funcall (p_e_bool) t)
                    (funcall (p_e_int) 3)
                    (funcall (p_e_double) 3.141592653)
                    (funcall (p_e_double) 3.0)
                    (funcall (p_e_string) "Hello, World!")
                    (funcall (p_e_string) "!@#$%^&*()\\\"
	")
                    (funcall (p_e_list (p_e_int)) (list 1 2 3))
                    (funcall (p_e_list (p_e_bool)) (list t nil t))
                    (funcall (p_e_ulist (p_e_int)) (list 3 2 1))
                    (funcall (p_e_idict (p_e_string)) (p_e_create-dict (list (cons 1 "one") (cons 2 "two"))))
                    (funcall (p_e_sdict (p_e_list (p_e_int))) (p_e_create-dict (list (cons "one" (list 1 2 3)) (cons "two" (list 4 5 6)))))
                    (funcall (p_e_option (p_e_int)) 42)
                    (funcall (p_e_option (p_e_int)) nil)   
                ))))
    (with-open-file (stream "stringify.out" :direction :output :if-exists :supersede)
        (format stream p_e_out)))
