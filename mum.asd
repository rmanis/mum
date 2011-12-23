;;;; mum.asd

(asdf:defsystem #:mum
  :depends-on (
               #:alexandria
               #:cl-json
               #:cl-who
               #:eager-future2
               #:hunchentoot
               #:parenscript
               #:ssmt
               #:bordeaux-threads
               )
  :components ((:file "package")
               (:file "macros" :depends-on ("package"))
               (:file "generics" :depends-on ("package"))
               (:file "mum" :depends-on ("package" "macros" "world"))
               (:file "action" :depends-on ("package"))
               (:file "arena" :depends-on ("package" "generics"))
	       (:file "collision" :depends-on ("package"))
               (:file "icon" :depends-on ("package"))
               (:file "position-mixin" :depends-on ("package"))
               (:file "turn" :depends-on ("package" "generics" "player"))
               (:file "player" :depends-on ("package" "position-mixin"))
               (:file "world" :depends-on ("package" "generics" "turn"))
               ))

