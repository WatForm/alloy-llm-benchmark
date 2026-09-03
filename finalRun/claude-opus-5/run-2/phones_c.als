sig Phone {
	requests : set Phone,
	connects : lone Phone,
	forward : lone Phone
}

fact {
	connects in { p : Phone, q : Phone | q in p.requests.*forward and no q.forward }
}

fact {
	all p : Phone | lone connects.p
}