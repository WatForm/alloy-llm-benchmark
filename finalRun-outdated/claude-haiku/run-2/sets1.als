sig Element {}

sig Set {
  elements: set Element
}

fact {
  some s1, s2: Set {
    no s: Set | s.elements = s1.elements + s2.elements
  }
}