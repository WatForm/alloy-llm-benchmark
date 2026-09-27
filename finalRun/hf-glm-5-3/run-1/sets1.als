sig Element {}

sig Set {
  elements : set Element
}

fact {
  some disj s1, s2 : Set |
    no s : Set | s.elements = s1.elements + s2.elements
}