abstract sig Num { val: one Int }

one sig S, E, N, D, M, O, R, Y extends Num {}

fact DigitRange {
  all n: Num | n.val >= 0 and n.val <= 9
}

fact DistinctDigits {
  all m, n: Num | m != n implies m.val != n.val
}

fun sumCarry[a, b: Num]: Int -> Int {
  let s = a.val + b.val |
    (s % 10) -> (s / 10)
}

fun fst[p: Int -> Int]: one Int {
  p.Int
}

fun snd[p: Int -> Int]: one Int {
  Int.p
}

fun val[p, q: Int -> Int]: one Int {
  (fst[p] + fst[q] + snd[q]) % 10
}

fact LeadingNonZero {
  M.val > 0
  S.val > 0
}

fact Alphametic {
  Y.val = val[sumCarry[D, E], sumCarry[D, E]]
  E.val = val[sumCarry[N, R], sumCarry[D, E]]
  N.val = val[sumCarry[E, O], sumCarry[N, R]]
  O.val = val[sumCarry[S, M], sumCarry[E, O]]
  M.val = snd[sumCarry[S, M]]
}

run {} for 5 Int