(defpackage :gtwiwtg-test
  (:use :cl :gtwiwtg :prove))

(in-package :gtwiwtg-test)

(defmacro autoplan (&rest test-forms)
  `(progn
     (plan ,(length test-forms))
     ,@test-forms
     (finalize)))

(autoplan 

 (is (take 4 (range)) '(0 1 2 3))


 (is (collect (range :from 2 :to -1 :by -0.5))
     '(2.0 1.5 1.0 0.5 0.0 -0.5))


 (is (collect (range :from 2 :to -1 :by -0.5 :inclusive t))
     '(2.0 1.5 1.0 0.5 0.0 -0.5 -1.0))

 (ok (let ((r (range)))
       (take 1 r)
       (gtwiwtg::stopped-p r)))

 (ok (not (gtwiwtg::stopped-p (range))))

 (is '(4 5 6) (collect (seq '(1 2 3 4 5 6) :start 3)))

 (is (collect (filter! (complement #'alpha-char-p) (seq "1234abcd5e6f")))
     '(#\1 #\2 #\3 #\4 #\5 #\6))

 (is '(1 2 3 5 8 13)
     (take 6 (from-recurrence #'+ 1 0)))


 (let ((s (open (asdf:system-source-file "gtwiwtg-test"))))
   (size (from-input-stream s (lambda (s) (read-line s nil nil))))
   (ok (not (open-stream-p s))))

 (let* ((file  (asdf:system-source-file "gtwiwtg-test"))
        (stat (osicat-posix:stat file)))
   (is (osicat-posix:stat-size stat)
       (1-  (size (file-bytes file))))) ;; b/c NIL is returned as the last generated value

 (let* ((file  (asdf:system-source-file "gtwiwtg-test"))
        (stat (osicat-posix:stat file)))
   (is (osicat-posix:stat-size stat)
       (1-  (size (file-chars file)))))

 (is (list 10 20 30 40)
     (take 4  (map! (lambda (x) (* x 10))
                    (range :from 1))))

 (is (list 20 40 60 80 100)
     (take 5 (map! (lambda (x) (* 10 x))
                   (filter! #'evenp (range :from 1)))))

 (is (list 0 1 2 3 #\a #\b #\c -10 -20 -30)
     (take 10 (concat! (times 4)
                       (seq "abc")
                       (range :from -10 :by -10))))

 (is '(("one" 1 :one) ("two" 2 :two) ("three" 3 :three))
     (collect (zip! (seq '("one" "two" "three"))
                    (range :from 1)
                    (repeater :one :two :three))))

(is '(-200 -180 -160 -140 -120 -100 -80 -60 -40 -20 -20 -15 -10 -5 0 0 1 2 3 4 5 6 7
      8 9 20 40 60 80 100 120 140 160 180 200)
    (collect
        (merge! #'< 
                (range :from -200 :by 20 :to 200 :inclusive t) 
                (times 10)
                (range :from -20 :by 5 :to 0))))


(is (collect
        (merge! #'< 
                (times 3)
                (range :from -200 :by 50 :to 200 :inclusive t) 
                (range :from 0 :by -5 :to -20 :inclusive t)))
    '(-200 -150 -100 -50 -20 -15 -10 -5 0 0 0 1 2 50 100 150 200))

;; don't be fooled by the last example. Merge is only guaranteed to
;; produce sorted outputs if the inputs are all sorted the same way.
;; here is an example showing that the end result isn't always sorted
;; if the arguments are sorted in different ways:

(is (collect
        (merge! #'< 
                (times 3)
                (range :from 200 :by -50 :to -200 :inclusive t) 
                (range :from 0 :by -5 :to -20 :inclusive t)))
    '(0 -5 -10 -15 -20 -50 -100 -150 -200 0 0 1 2 50 100 150 200))

(is (collect (intersperse! (times 5) (repeater 'a 'b 'c) (range :by -10)))
    '(0 A 0 1 B -10 2 C -20 3 A -30 4 B -40))

(is (collect (truncate! 20 (range)))
    '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19))

(is (pick-out '(4 1 1 4 2) (seq "generators"))
    '(#\r #\e #\e #\r #\n))


 )


