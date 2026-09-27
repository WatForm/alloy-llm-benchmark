sig A, B, C {}

rel r : A → B → C

fact {
  all a : A | some r[a]
}