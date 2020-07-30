;;;; gtwiwtg.asd

(asdf:defsystem #:gtwiwtg
  :description "Generators and consumers."
  :author "Colin Okay <cbeok@protonmail.com>"
  :license  "GPLv3"
  :version "0.1.1"
  :serial t
  :components ((:file "package")
               (:file "gtwiwtg")
               (:file "anaphora"))
  :in-order-to ((test-op (test-op gtwiwtg-test))))
