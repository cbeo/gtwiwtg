# GTWIWTG

*Generators The Way I Want Them Generated*

A naive generator library that doesn't use fancy pants concepts like
first class continuations.

The GTWIWTG library is meant to be small, explorable, and understandable.
The source code is meant to be readible and easy to
follow.

Every symbol exported from the `GTWIWTG` package has a useful
docstring. Many docstrings include examples of use.

## Installation 

    git clone https://github.com/cbeo/gtwiwtg /path/to/quicklisp/local-projects/

``` lisp

(ql:quickload :gtwiwtg)
(use-package :gtwiwtg)

```

## First, Here's the Action

Here are a few examples to show you what you can do.  A more involved
example apears at the end of the document, following the tutorial.

### All The Primes

``` lisp

> (defun prime-p (n)
    "Naive test for primes."
    (loop
       :for x :from 2 :upto (sqrt n)
       :when (zerop (mod n x)) :do (return nil)
       :finally (return t)))

> (defun all-primes ()
    "Creates a generator that produces an infinite series of primes."
     (filter! #'prime-p (range :from 2)))

> (take 10 (all-primes)) ;; (2 3 5 7 11 13 17 19 23 29)

```

### Fun With Fibbonacci

``` lisp 

> (defun fibs ()
    "Creates an infinite series of Fibbonacci numbers."
    (from-recurrence
     (lambda (n-1 n-2) (+ n-1 n-2))
     1 0))

;; First ten Fibbonacci numbers
> (take 10 (fibs)) ;; (1 2 3 5 8 13 21 34 55 89) 

;; Just the 40th Fibbonacci number, indexed from 0
> (car (pick-out '(40) (fibs))) ;; 267914296

```

### A Kind Of Grep

``` lisp

> (defun grepper (pattern file)
   (filter! (lambda (idx-line) (search pattern (second idx-line)))
            (zip! (range) (file-lines file))))


> (for (idx line) (grepper "defun" "examples.lisp")
     (format t "~4a: ~a~%" idx line))


12  : (defun prime-p (n)
19  : (defun all-primes ()
37  : (defun fibs ()
52  : (defun fill-and-insert (idx elem vec buffer)
69  : (defun thread-through (elem vec)
86  : (defun perms (vec)
104 : ;; (defun perms (vec)
115 : (defun grepper (pattern file)

```

## Tutorial

GTWIWTG is a tiny library for creating and using generators. 

If you have never heard of generators before, let me offer a
definition.

A generator is an object that can produce a series of values, one
value at a time.  Generators are sometimes convenient when you want to
deal with series that are too long to fit into memory. They also help
when you want to generate sequential data using functions.

### Three Kinds Of Function 

In GTWIWTG, there are functions that *construct* generators, functions
that *combine* generators, and functions and macros that *consume*
generators. 

### The Breadwinning Constructors 

The two most common generator constructors are:

- `(range &key (from 0) to (by 1) inclusive)`
- `(seq sequence)`

Here are some examples using `range` and `seq` to make generators. 

``` lisp

  ;; all positive integers starting at 0
> (range)

#<GTWIWTG::GENERATOR! {1001A7DF63}>

 ;; positive integers from 0 to 9
> (range :to 10)

#<GTWIWTG::GENERATOR! {1001A90CA3}> 

;; positive integers from 0 to 10 
> (range :to 10 :inclusive t) 

#<GTWIWTG::GENERATOR! {1001A90CA3}> 

;; numbers between 4.0 and -15.7 incremented by -0.44
> (range :from 4 :to -15.7 :by -0.44) 

#<GTWIWTG::GENERATOR! {1001B09D63}>

;; the characters in the string "hello"
> (seq "hello")

#<GTWIWTG::GENERATOR! {1001B93E63}>

;; the symbols in the list
> (seq '(h e l l o))

#<GTWIWTG::GENERATOR! {1001BAB273}>

;; the symbols in the vector 
> (seq #('h 'e 'l 'l 'o))

#<GTWIWTG::GENERATOR! {1001BE4883}>

```

As you can see, generators are objects. Nothing is generated until you
consume a generator. As a quick, but greatly impoverished, example,
consider this:

``` lisp 

;; get the first 4 numbers from the range starting at 20
> (take 4 (range :from 20))

(20 21 22 23)

```

### Other Constructors

Here is a brief listing of the other generator constructors in GTWIWTG:

- `(times n)` is shorthand for `(range :to n)`
- `(repeater &rest args)` repeats its arguments in order, looping forever.
- `(noise &optional (arg 1.0))` an infinite sequence of random numbers
- `(from-thunk thunk)` an infinite sequence of calls to `(funcall thunk)`
- `(from-thunk-until thunk &optional until clean-up)` like `from-thunk`, but stops when `(funcall until)` is non nil. Runs the thunk `clean-up` when done.
- `(from-thunk-times thunk n)` like `from-thunk` but stops after `n` times.
- `(from-recurrence fn n-1 &rest n-m)` generate using a recurrence relation 
- `(from-input-stream stream reader)` turn a stream into a generator
- `(file-lines file)` a file-backed generator. Produces lines from that file (strings)
- `(file-chars file)` a file-backed generator. Produces characters from that file.
- `(file-bytes file)` a file-backed generator. Produces bytes from that file.

You can see some of these in action in the examples section at the top of this document.

### The Combination and Transformation Functions

You can create more intersting and more specific generators by using a
few higher-order functions to combine and transform simple generators.

These transformations are desirable because they can be performed
before any elements are produced.

That is, if you think of a generator as a computation that produces a
series of values, then transformation functions allow you to
incrementally "build up" a desired computation before it is run.

The three core transformation functions are:

- `(map! fn gen &rest gens)` makes a new generator by mapping `fn` over other generators
- `(filter! pred gen)` makes a new generator by discarding some elements that
- `(inflate! fn gen)` The function `fn` should make  new generators using the values produced by the generator `gen`. The `inflate!` function combines all those "intermediate" generators into a single generator.

Admittedly, the behavior of `inflate!` is difficult to grok by reading a description. 
Once you begin to use it, however, it becomes indispensible.

[NB: `inflate!` is really the monadic bind operator in disguise.]

Here are some simple examples of their use:

``` lisp

;; map cons over two generators
> (map! #'cons (times 3) 
               (range :from 8))

#<GTWIWTG::GENERATOR! {1001CB28D3}>

;; consuming the above using collect
> (collect (map! #'cons (times 3) (range :from 8)))

((0 . 8) (1 . 9) (2 . 10))

;; Notice that map! stops generating after 3 steps even though 
;; (range :from 8) is an infinite generator. This is because (times 3)
;; only generates 3 values.

;; get just the even values from a generator: 
> (collect (filter! #'evenp (times 10)))

(0 2 4 6 8)

;; generate (times N) for each N in the range 1 to 4
> (collect (inflate! #'times (range :from 1 :to 4 :inclusive t)))
(0 0 1 0 1 2 0 1 2 3)

;; In the above example, you can see that 
;; first 0 is generated     (times 1)
;; then 0 1                 (times 2)
;; then 0 1 2               (times 3)
;; and finally 0 1 2 3      (times 4)

```

### The Other Combinations and Transformations 

- `(zip! gen1 &rest gens)` is shorthand for `(map! #'list gen1 gen2 ...)`
- `(indexed! gen)` is shorthand for `(zip! (range) gen)`
- `(concat! gen &rest gens)` is shorthand for `(inflate! #'identity (seq (list* gen1 gen2 ...)))`
- `(skip! n gen)` produces a generator by skipping the first `n` values in `gen`
- `(skip-while! pred gen)` produces a generator by skippng elements of `gen` while `pred` is `t`
- `(merge! comp gen1 gen2 &rest gens)` emulates the behavior of `merge` but for generators

And some experimental tools:

- `(nfurcate! n gen)` returns a list of `n` new generators, each
  producing the same elements as of `gen`.
- `(partition! pred gen)` returns a list of two new generators, the
  first generating the memebers of `gen` that pass the predicate
  `pred`, and the second generating those that don't.
  
Both of the above are marked as EXPERIMENTAL because they may not be
in line with the the spirit of this library. I wanted the library to
produce constant-memory operations. However, when you consume the
generators that the above forms produce, then new memory will be
consed during consumption. See the docstrings for both forms for more details.

### The Fundamental Consumer

Finally! Once you have built up your generators using *constructors*
and *combinations*, you want to actually use them for something. This
is where *consumers* come in.

There is one fundamental consumer, a macro, called `for`.  (*Triumphant Horns Play*)

Every other consumer in `GTWIWTG` uses `for` under the good.  

Here is how it looks when you use it:

``` lisp

> (for x (times 3)
    (print x))

0 
1 
2 

> (for (x y) (zip! (seq "hello") (range))
    (format t "~a -- ~a~%" x y)
    (when (= 4 y) 
      (princ "world!")
      (terpri))

h -- 0
e -- 1
l -- 2
l -- 3
o -- 4
world!

> (let* ((ten-times (times 10))
         (doubled (map! (lambda (x) (* 2 x)) ten-times))
         (incremented (map! #'1+ doubled))
         (indexed (zip! (range) incremented)))
    (for (index number) indexed
      (princ index) 
      (princ " -- ") 
      (princ number) 
      (terpri)))

0 -- 1
1 -- 3
2 -- 5
3 -- 7
4 -- 9
5 -- 11
6 -- 13
7 -- 15
8 -- 17
9 -- 19

```

As you can see `for` has 3 basic parts: a *binding form*, a *generator
form*, and a *body*. 

The binding form is either a variable, like `x` above, or is a form
suitable for use in the binding form of a `DESTRUCTURING-BIND`, like
`(x y)` above.

On each iteration, the variables in the binding form are bound to
successive values generated by the generator form. Notice that you do
not need to inline your generator form, you can build it up and pass
it in as in the thrid example above.

Finally, the body is evaluated for each iteration.

[Aside: `for` used to be called `iter`, but I didn't want to step on
the toes of `series` and `iterate` users :P].

### Generators are Consumed at Most Once

Even if you don't think you're "using up" the whole generator, a
generator can only be passed to a single consumer. Once that consumer
finishes, the generator is consumed.  Here is an example:

``` lisp

>(let ((foo (seq "foobar")))
   (print (take 2 foo))
   (print (collect foo)))

(#\f #\o) 
NIL 

```

Even though you only *seemed* to use the first two members of the
generator `foo`, the `take` form will mark the generator as having
been consumed in its entirety. 

That is, even when the whole sequence was not actually generated, a
consuming form leaves its generator in an unusable state.  This
approach has been taken in order to automatically close streams for
stream-backed generators - i.e. it has been done in the spirit of
letting you not have to think about how generators work.

You need only remember the rule: Generators Are Consumed At Most Once.


### A Word Of Warning!

(Or, there's a reason those forms all end in `!`.)

You must be cautious when incrementally building up generators. The
reason for caution is that generators cannot be "combined twice", but
you may be tempted to try doing just that. 

I.e.These generators are not functional objects. Combining them with
one other effectively "destroys" them as independent objects, by
marking them as unfit for use in other combining forms.

[Aside: This was done for efficiency reasons, and I might make a
"purely functional" parallel universe for these generators in the
future.]

The library tries to help you out by signalling an error whenever you
try to do something that would lead to _mangled memory_.  Each
docstring provides details about when error conditions are signalled
for each combining form. Don't quote me on it, but I *think* that the
library will prevent you from making generators with surprising
(i.e. erroneous) behavior.

Here is an example to show you the illegal behavior:

``` lisp

> (let ((ten-times (times 10)))
    (zip! ten-times ten-times))

; Evaluation aborted on #<SIMPLE-ERROR "~@<The assertion ~S failed~:[.~:; ~
                                           with ~:*~{~S = ~S~^, ~}.~]~:@>" {10046A61D3}>.

```

The gist is that we tried to zip a generator with itself. Such
behavior is not allowed. Generally speaking, if you pass a generator
to more than one combining form (all forms that end in a `!`), or if
you pass the same generator to such a form twice, then an error will
be raised and new the generator will not be built.

An ongoing goal is to make those errors nicer to look at so that you
can more easily pin-point where you goofed.

### The Accumulating Consumer

The next most common consuming form is `fold`, which lets you consume
values produced by a generator while accumulating some data along the
way.

Here is how you would do a classic summing operation:

``` lisp
> (fold (sum 0) (x (times 10)) 
        (+ sum x))
45
```

The syntax is `(fold (acc init) (iter-var gen) update)`.

First, you declare and initialize an accumulator variable. In the
above that is the form `(sum 0)`, which declares a variable called
`sum` initialized to `0`. 

Next comes your iteration variable and generator form. These have the
same syntax as `for`. So in the above we bind a variable `x` to each
successive value generated by `(times 10)`.

Finally, you write a *single update form* whose value becomes bound to your
accumulator variable. In the above example `sum` is set to `(+ sum x)`.

The `fold` form returns the final value of the accumulator.

Here are some more folds:

``` lisp

;; some funky calculation 

> (fold (acc 0)
        ((x y) (zip! (times 10) (range :by -1)))
        (sqrt (+ acc (* x y))))
#C(0.444279 8.986663)

;; Example: building a data structure

> (fold (plist nil) 
        ((key val)
         (zip! (seq '(:name :occupation :hobbies))
               (seq '("buckaroo banzai" 
                      "rocker" 
                      ("neuroscience" "particle physics" "piloting fighter jets")))))
         (cons key (cons val plist)))

 (:HOBBIES ("neuroscience" "particle physics" "piloting fighter jets")
  :OCCUPATION "rocker" :NAME "buckaroo banzai")

```



### The Remaining Consumers

All of the remaining consumers are regular functions that have been
built using `for` and `fold`. They are:

- `(collect gen)` collects the values of `gen` into a list
- `(take n gen)` collects the first `n` values of `gen` into a list
- `(pick-out indices gen)` see example below
- `(size gen)` consumes a generator, returning the number of values it produced
- `(maximum gen)` returns the maximum among the values in gen (subject to change)
- `(minimum gen)` see maximum 
- `(average gen)` returns the average of the values produced by gen
- `(argmax fn gen)` returns a pair `(val . x)` where `val` is the value of `gen` for which `(funcal fn val)` is maximal. `x` is `(funcall fn val)`
- `(argmin fn gen)` see argmax 

The `pick-out` consumer is interesting enough to see a quick example of:

``` lisp
;; pick out characters and index 1 and index 4
> (pick-out '(1 4) (seq "generators"))
(#\e #\r)

;; you can do this in any order
> (pick-out '(4 1) (seq "generators"))
(#\r #\e)

;; you can even repeat indices
> (pick-out '(4 1 1 4 2) (seq "generators"))
(#\r #\e #\e #\r #\n)
```

## The Permutations Example

One final example to show you what you can do. Here is a function that
generates all of the permutations of a sequence passed to it, one at a
time. It is a good example of the usefulness of `inflate!`.

``` lisp

(defun perms (vec)
  "Creates a generator that produces all of the permutations of the
   vector VEC, one at a time."
  (if (= 1 (length vec)) (seq (list vec))
      (let ((elem (elt vec 0))
            (subperms (perms (make-array (1- (length vec))
                                         :displaced-to vec
                                         :displaced-index-offset 1
                                         :element-type (array-element-type vec)))))
        (inflate! (lambda (subperm) (thread-through elem subperm)) 
                  subperms))))
```

The interesting bit about this is that we recursively compute
generators on the sub-arrays in a classic divide-and-conquer way.  The
code is made signifiantly noisier by the use of displaced arrays, but
is made signifiantly more memory efficient as well.

For each "sub permutation", we create a new generator using a
generator constructor called `thread-through`.

``` lisp
(defun thread-through (elem vec)
  "Creates a generator that produces a series of N vectors of length
   N, where N is one greater than the length of VEC.  The vectors
   produced by this generator have the same contents as VEC but have ELEM
   inserted at each possible spot, N spots in all. 

   Note: The generator reuses the memory that it returns on each step. If
   you intend to collect the values of the generator, you should copy
   them on each iteration."
   
  (let ((buffer (concatenate 'vector vec (list elem)))) ;; reusable buffer
    (map! (lambda (idx)
            (fill-and-insert idx elem vec buffer)
            buffer)
          (range :from 0 :to (length vec) :inclusive t))))

```

And this function uses a utility function called `fill-and-insert`
that just fills a buffer:

``` lisp

(defun fill-and-insert (idx elem vec buffer)
  "A utilty function that modifies BUFFER. 

The length of BUFFER is assumed to be one greater than the length of
VEC.

This function fills the first IDX fields of BUFFER with the first IDX
fields of VEC. It fills the field of BUFFER at IDX with ELEM. And it fills
the remaining fields of BUFFER with the remaining fields of VEC.
"

  (loop :for i :below (length buffer)
     :when (= i idx) :do (setf (aref buffer idx) elem)
     :when (< i idx) :do (setf (aref buffer i)
                               (aref vec i))
     :when (> i idx) :do (setf (aref buffer i)
                               (aref vec (1- i))))  )

```


And here's a quick demo of its use:

``` lisp

;; the map! is to turn vectors back into strings for ease of viewing
(for perm (map! (lambda (x) (concatenate 'string x)) 
                (perms "abcd"))
  (print perm))

"abcd" 
"bacd" 
"bcad" 
"bcda" 
"acbd" 
"cabd" 
"cbad" 
"cbda" 
"acdb" 
"cadb" 
"cdab" 
"cdba" 
"abdc" 
"badc" 
"bdac" 
"bdca" 
"adbc" 
"dabc" 
"dbac" 
"dbca" 
"adcb" 
"dacb" 
"dcab" 
"dcba" 

```

We could have generated all 121645100408832000 permutations of
"generators are cool", and, though it would have taken us an eternity
(approximately 1000 years on a single core of my machine), the memory
consumption would stay at an even keel.



