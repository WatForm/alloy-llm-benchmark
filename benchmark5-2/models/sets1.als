module chapter5/sets1 ----- page 156

sig Set {
	elements: set Element
}

sig Element {}

fact NotClosed {
	some s0, s1: Set |
		all s2: Set |
			s2.elements != s0.elements + s1.elements
}
