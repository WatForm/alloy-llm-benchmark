sig Set {
    elements: set Element
}

sig Element {}

fact {
    // Conditions for sets and elements
    no Set.elements & Set.elements // Sets are disjoint
    all s1, s2: Set | s1 != s2 implies (s1.elements + s2.elements) in Set.elements // Union of elements of two sets is not another set
} 

pred example {
    some s1, s2: Set | s1 != s2 and (s1.elements + s2.elements) !in Set.elements 
}

run example for 5 but 2 Set, 5 Element