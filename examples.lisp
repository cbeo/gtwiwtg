(defpackage #:gtwiwtg.examples
  (:use #:cl #:gtwiwtg)
  (:export
   #:perms
   #:all-primes
   #:fibs
   #:a-kind-of-grep))

(in-package :gtwiwtg.examples)

;;; PRIMES ;;; 

(defun prime-p (n)
  "Naive test for primes."
  (loop
     :for x :from 2 :upto (sqrt n)
     :when (zerop (mod n x)) :do (return nil)
     :finally (return t)))

(defun all-primes ()
  "Creates a generator that produces an infinite series of primes."
  (filter! #'prime-p (range :from 2)))

;; Here is an example of using all-primes to get a list of the 0th,
;; 10th and 30th prime numbers, indexed starting at 0:

(pick-out '(0 10 30) (all-primes)) ;; (2 31 127)

;; Note that you can PICK-OUT in any order, and repeat too:
(pick-out '(30 10 0 10) (all-primes)) ;; (127 31 2 31)

;; get the 10 primes after the 20th prime

(take 10 (skip! 20 (all-primes))) ;; (73 79 83 89 97 101 103 107 109 113)

;;; FIBBONACCI NUMBERS ;;;

(defun fibs ()
  "Creates an infinite series of Fibbonacci numbers."
  (from-recurrence
   (lambda (n-1 n-2) (+ n-1 n-2))
   1 0))

;; First ten Fibbonacci numbers
(take 10 (fibs)) ;; (1 2 3 5 8 13 21 34 55 89) 

;; Just the 40th Fibbonacci number, indexed from 0
(car (pick-out '(40) (fibs))) ;; 267914296


;;; PERMUTATIONS ;;;

(defun fill-and-insert (idx elem vec buffer)
  "A utilty function that modifies BUFFER. 

The length of BUFFER is assumed to be one greater than the length of
VEC.

This function fills the first IDX fields of BUFFER with the first IDX
fields of VEC. Fills the field of BUFFER at IDX with ELEM.  Fills the
remaining fields of BUFFER with the remaining fields of VEC.
"
  (loop :for i :below (length buffer)
     :when (= i idx) :do (setf (aref buffer idx) elem)
     :when (< i idx) :do (setf (aref buffer i)
                               (aref vec i))
     :when (> i idx) :do (setf (aref buffer i)
                               (aref vec (1- i))))  )

(defun thread-through (elem vec)
  "Creates a generator that produces a series of N vectors of length
N, where N is one greater than the length of VEC.  The vectors
produced by this generator have the same elements of VEC but have ELEM
inserted at each possible spot, N spots in all. 

Note: The generator reuses the memory that it returns on each step. If
you intend to collect to products of the generator, you should copy
them to somehow first.
"
  (let ((buffer (concatenate 'vector vec (list elem)))) ;; reusable buffer
    (map! (lambda (idx)
            (fill-and-insert idx elem vec buffer)
            buffer)
          (range :from 0 :to (length vec) :inclusive t))))


(defun perms (vec)
  "Creates a generator that produces all of the permutations of the
vector VEC, one at a time."
  (if (= 1 (length vec)) (seq (list vec))
      (let ((elem (elt vec 0))
            (subperms (perms (make-array (1- (length vec))
                                         :displaced-to vec
                                         :displaced-index-offset 1
                                         :element-type (array-element-type vec)))))
        (inflate! (lambda (subperm) (thread-through elem subperm)) subperms))))

;; In the above, the interesting bit is in the recursive step, and in
;; the call to inflate. Most of the noise in the above has to do with
;; the creation of the displaced array (for memory conservation
;; purposes) that is recursively apssed to perms.

;; the whole thing could have been written:
;;
;; (defun perms (vec)
;;   (if (= 1 (length vec)) (seq (list vec))
;;       (let ((elem (elt vec 0))
;;             (subperms (perms (subseq vec 1))))
;;         (inflate! (lambda (subperm) (thread-through elem subperm))
;;                   subperms))))
;;
;; which looks a little nicer but is less kind to the heap and to GC.

;;; A kind of Grep ;;;

(defun grepper (pattern file)
  (filter! (lambda (idx-line) (search pattern (second idx-line)))
           (zip! (range) (file-lines file))))



