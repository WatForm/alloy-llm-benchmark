sig Element {}

sig Set {
  elements: set Element
}

fact {
  some s1, s2: Set | not (some s3: Set | s3.elements = s1.elements + s2.elements)
}