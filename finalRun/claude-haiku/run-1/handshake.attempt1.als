sig Person {
  spouse: one Person,
  shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
  Person = Jocelyn + Hilary
}

fact {
  all p: Person | p not in p.shaken and p.spouse not in p.shaken
}

fact {
  all p1, p2: Person | p1 in p2.shaken iff p2 in p1.shaken
}

fact {
  all p: Person | p.spouse.spouse = p
}

fact {
  all p: Person | p.spouse != p
}

fact {
  Hilary.spouse = Jocelyn
}

fact {
  all p1, p2: Person | p1 != p2 and p1 != Jocelyn and p2 != Jocelyn implies #p1.shaken != #p2.shaken
}