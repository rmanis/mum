;;;; action.lisp

(in-package #:mum)

(defclass action ()
  ((verb
    :accessor verb
    :initarg :verb
    :type symbol
    :documentation "A keyword for this action, or an uninterned symbol
representing an unrecognized action.")
   (arguments
    :accessor arguments
    :initarg :arguments
    :initform nil
    :type list))
  (:documentation "taken during a turn"))

(defmethod print-object ((action action) stream)
  (print-unreadable-object (action stream :type t :identity t)
    (format stream "~S ~S" (verb action) (arguments action))))

(defparameter *action-verbs*
  '(:talk :move :stay)
  "All recognized action verbs.")

(defun quasi-intern (string-designator symbol-list)
  "Returns the symbol from the SYMBOL-LIST that is STRING-EQUAL to the
  STRING-DESIGNATOR, or an uninterned symbol if no such symbol is
  found.  STRING-UPCASE is called on the string designator if a symbol
  is made from it."
  (or (find string-designator symbol-list
	    :test #'string-equal)
      (make-symbol (string-upcase string-designator))))

(defun make-action (verb arguments)
  (declare (type string verb)
           (type list arguments))
  (make-instance 'action
                 :verb (quasi-intern verb *action-verbs*)
                 :arguments arguments))

(defgeneric action-fully-specified-p-2 (verb arguments))

(defun action-fully-specified-p (action)
  (action-fully-specified-p-2 (verb action) (arguments action)))

(defgeneric action-prompt-3 (player verb arguments))

(defun action-prompt (action player)
  (action-prompt-3 player (verb action) (arguments action)))

(defmethod action-prompt-3 (player verb arguments)
  "You wanna what with a what!?")

(defmethod action-fully-specified-p-2 (verb arguments)
  nil)

(defvar *directions*
  '((:SW . (-1  1 0))
    (:S  . ( 0  1 0))
    (:SE . ( 1  1 0))
    (:W  . (-1  0 0))
    (:.  . ( 0  0 0))
    (:E  . ( 1  0 0))
    (:NW . (-1 -1 0))
    (:N  . ( 0 -1 0))
    (:NE . ( 1 -1 0))))

(defmethod action-fully-specified-p-2 ((verb (eql :move)) (arguments list))
  "One argument: the direction.  Must be in *DIRECTIONS*."
  (and
   (= (length arguments) 1)
   (let ((dir (quasi-intern (first arguments)
			    (mapcar #'car *directions*))))
     (assoc dir
	    *directions*))))

(defmethod action-fully-specified-p-2 ((verb (eql :talk)) (arguments list))
  "One argument: the text."
  (> (length arguments) 0))

(defmethod action-fully-specified-p-2 ((verb (eql :stay)) (arguments list))
  "No arguments."
  t)


(defgeneric perform-action-5 (world player turn verb arguments))

(defun perform-action (world player turn action)
  (perform-action-5 world player turn (verb action) (arguments action)))

(defmethod perform-action-5 (world player turn (verb (eql :move)) (arguments list))
  (let ((direction (quasi-intern (first arguments)
				 (mapcar #'car *directions*))))
    (setf (coordinates player)
	  (mapcar #'+
		  (coordinates player)
		  (cdr (assoc direction
			      *directions*))))
    (collide player (arena turn) direction turn)))

(defmethod perform-action-5 (world player turn (verb (eql :talk)) (arguments list))
  (message-all-players turn (format nil "~A says \"~A\". (clock ~D)" (name player) (first arguments) (clock turn))))

(defmethod perform-action-5 (world player turn (verb (eql :stay)) (arguments list))
  ; nop
  )
