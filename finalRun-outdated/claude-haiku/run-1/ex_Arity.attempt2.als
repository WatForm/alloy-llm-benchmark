sig A, B, C {}

one sig Helper {
  r: A -> B -> C
}

fact {
  all a: A, b: B | one c: C | a -> b -> c in Helper.r
}