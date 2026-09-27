```alloy
sig Phone {
	requests: set Phone,
	connects: lone Phone,
	forward: lone Phone
}

fact {
	connects in { p1, p2: Phone | some d: p1.requests | p2 in d.*forward and no p2.forward }
	all p: Phone | lone connects.p
}
```