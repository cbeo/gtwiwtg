(in-package #:gtwiwtg.anaphora)

(defmacro afor (generator &body body)
  "Anaphoric FOR. Binds the values produced by GENERATOR to the variable IT.

Example: 

> (afor (times 3) (print it))
0
1
2

"
  `(for it ,expr ,@body))

(defmacro afold (init generator update)
  "Anaphoric FOLD. Binds the values produced by GENERATOR to IT, and
binds the accumulating variable to ACC.

Example:

> (afold 0 (times 10) (+ acc it))
45

"
  `(fold (acc ,init) (it ,generator) ,update))
