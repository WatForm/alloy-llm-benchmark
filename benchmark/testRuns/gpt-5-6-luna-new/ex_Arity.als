sig A {
    r: B -> C
}

sig B {}

sig C {}

fact {
    all a: A | some a.r
}