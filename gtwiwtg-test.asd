;;;; gtwiwtg-test.asd

(asdf:defsystem #:gtwiwtg-test
  :description "tests for gtwiwtg"
  :author "Colin Okay <okay@toyful.space>"
  :license "GPLv3"
  :version "0.1.0"
  :depends-on (:gtwiwtg :prove :osicat)
  :defsystem-depends-on (:prove-asdf)
  :components ((:test-file "gtwiwtg-test")))
