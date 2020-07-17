;;;; gtwiwtg-test.asd

(asdf:defsystem #:gtwiwtg-test
  :depends-on (:gtwiwtg :prove :osicat)
  :defsystem-depends-on (:prove-asdf)
  :components ((:test-file "gtwiwtg-test")))
