sig Person {
	spouse: one Person,
	shaken: set Person
}

one sig Jocelyn extends Person {}
one sig Hilary extends Person {}

fact {
	no p: Person | p in p.shaken or p.spouse in p.shaken
}

fact {
	all p, q: Person | p in q.shaken implies q in p.shaken
}

fact {
	all p, q: Person | p != q implies (p.spouse = q implies q.spouse = p)
}

fact {
	all p, q: Person | p != q implies p.spouse != q.spouse
}

fact {
	all p: Person | p.spouse.spouse = p
}

fact {
	no p: Person | p.spouse = p
}

fact {
	Hilary.spouse = Jocelyn
}

fact {
	all p, q: Person - Jocelyn | p != q implies #p.shaken != #q.shaken
}