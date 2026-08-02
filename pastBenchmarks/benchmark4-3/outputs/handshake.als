sig Person {
  spouse: one Person,
  shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
  all p: Person | p not in p.shaken and p.spouse not in p.shaken
}

fact {
  all p, q: Person | p in q.shaken => q in p.shaken
}

fact {
  all disj p, q: Person | p.spouse = q => q.spouse = p
}

fact {
  all disj p, q: Person | p.spouse != q.spouse
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
  all disj p, q: Person - Jocelyn | #p.shaken != #q.shaken
}

fact {
  all disj p, q: Person - Jocelyn | #p.shaken != #q.shaken
}