sig A {
    r: B -> C
}

sig B {}
sig C {}

fact {
    all a: A | all b: B | one a.r[b]
}