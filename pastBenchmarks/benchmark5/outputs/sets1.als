sig Element {}

sig Set {
  elements: set Element
}

fact {
  some disj s1, s2: Set |
    no s3: Set | s3.elements = s1.elements + s2.elements
}