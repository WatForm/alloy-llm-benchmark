sig A {
  r : B → C
}

sig B, C {}

fact {
  all a : A | some r[a]
}