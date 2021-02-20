;;;; gtwiwtg.asd

(asdf:defsystem #:gtwiwtg
  :description "Lazy-ish iterators"
  :author "Colin Okay <okay@toyful.space>"
  :license  "GPLv3"
  :version "0.1.2"
  :serial t
  :components ((:file "package")
               (:file "gtwiwtg")
               (:file "anaphora"))
  :in-order-to ((test-op (test-op gtwiwtg-test))))
