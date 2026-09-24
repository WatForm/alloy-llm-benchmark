sig B {}
sig C {}
sig A {
    r: B -> C
}

fact {
    r in A one -> (B -> C)
}