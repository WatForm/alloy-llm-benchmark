sig Set {
  elements: set Element
}

sig Element {}

fact disjoint {
  no (Set & Element)
}

fact unionProperty {
  some s1, s2: Set |
    s1 != s2 and
    all s3: Set | (s1.elements + s2.elements) != s3.elements
}