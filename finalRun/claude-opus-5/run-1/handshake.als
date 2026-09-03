sig Person {
	spouse: one Person,
	shaken: set Person
}

one sig Jocelyn extends Person {}
one sig Hilary extends Person {}

fact NotSelfOrSpouseShaken {
	all p: Person | p not in p.shaken and p.spouse not in p.shaken
}

fact SymmetricShaken {
	all p, q: Person | p in q.shaken implies q in p.shaken
}

fact SymmetricSpouse {
	all p, q: Person | p != q implies (p.spouse = q implies q.spouse = p)
}

fact DistinctSpouses {
	all p, q: Person | p != q implies p.spouse != q.spouse
}

fact SpouseOfSpouse {
	all p: Person | p.spouse.spouse = p
}

fact NoSelfSpouse {
	no p: Person | p.spouse = p
}

fact HilarySpouse {
	Hilary.spouse = Jocelyn
}

fact DistinctShakenCounts {
	all p, q: Person - Jocelyn | p != q implies #p.shaken != #q.shaken
}

fact NoTwoSameShakenCount {
	all p, q: Person - Jocelyn | p != q implies #p.shaken != #q.shaken
}