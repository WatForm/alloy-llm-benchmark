sig B, C {}

sig A {
  r: set (B -> C)
}

fact {
  all a: A | some a.r
}