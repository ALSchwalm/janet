# Copyright (c) 2019 Calvin Rose & contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

(import test/helper :prefix "" :exit true)
(start-suite 5)

# some tests typed array

(defn inspect-tarray
  [x]
  (def a @[])
  (for i 0 (tarray/length x) (array/push a (x i)))
  (pp a))

(assert-no-error
 "create some typed arrays"
 (do
   (def a (tarray/new :float64 10))
   (def b (tarray/new :float64 5 2 0 a))
   (def c (tarray/new :uint32 20))))

(assert-no-error
 "create some typed arrays from a buffer"
 (do
   (def buf (tarray/buffer (+ 64 (* (+ 1 (* (- 10 1) 2)) 8))))
   (def b (tarray/new :float64 10 2 64 buf))))

(def a (tarray/new :float64 10))
(def b (tarray/new :float64 5 2 0 a))

(assert-no-error
 "fill tarray"
 (for i 0 (tarray/length a)
      (set (a i) i)))

(assert (= (tarray/buffer a) (tarray/buffer b)) "tarray views pointing same buffer")
(assert (= (a 2) (b 1) ) "tarray views pointing same buffer")
(assert (= ((tarray/slice b) 3) (b 3) (a 6) 6) "tarray slice")
(assert (= ((tarray/slice b 1) 2) (b 3) (a 6) 6) "tarray slice")

(assert (= ((unmarshal (marshal b)) 3) (b 3)) "marshal")

# Array remove

(assert (deep= (array/remove @[1 2 3 4 5] 2) @[1 2 4 5]) "array/remove 1")
(assert (deep= (array/remove @[1 2 3 4 5] 2 2) @[1 2 5]) "array/remove 2")
(assert (deep= (array/remove @[1 2 3 4 5] 2 200) @[1 2]) "array/remove 3")
(assert (deep= (array/remove @[1 2 3 4 5] -3 200) @[1 2 3]) "array/remove 4")

# Break

(var summation 0)
(for i 0 10
  (+= summation i)
  (if (= i 7) (break)))
(assert (= summation 28) "break 1")

(assert (= nil ((fn [] (break) 4))) "break 2")

# Break with value

# Shouldn't error out
(assert-no-error "break 3" (for i 0 10 (if (> i 8) (break i))))
(assert-no-error "break 4" ((fn [i] (if (> i 8) (break i))) 100))

# drop-until

(assert (deep= (drop-until pos? @[]) @[]) "drop-until 1")
(assert (deep= (drop-until pos? @[1 2 3]) @[1 2 3]) "drop-until 2")
(assert (deep= (drop-until pos? @[-1 -2 -3]) @[]) "drop-until 3")
(assert (deep= (drop-until pos? @[-1 -2 3]) @[3]) "drop-until 4")
(assert (deep= (drop-until pos? @[-1 1 -2]) @[1 -2]) "drop-until 5")

# Quasiquote bracketed tuples
(assert (= (tuple/type ~[1 2 3]) (tuple/type '[1 2 3])) "quasiquote bracket tuples")

(end-suite)
