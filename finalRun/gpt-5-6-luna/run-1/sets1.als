sig Set {
    elements: set Element
}

sig Element {}

fact {
    some s1, s2: Set |
        not (s1.elements + s2.elements in Set)
}