sig Person {
  spouse: one Person,
  shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
  all p: Person | p not in p.shaken and p.spouse not in p.shaken
}

fact {
  all p, q: Person | p in q.shaken implies q in p.shaken
}

fact {
  all p, q: Person | p != q and p.spouse = q implies q.spouse = p
}

fact {
  all p, q: Person | p != q implies p.spouse != q.spouse
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
  all p, q: Person - Jocelyn | p != q implies #p.shaken != #q.shaken
}

fact {
  all p, q: Person - Jocelyn | p != q implies #p.shaken != #q.shaken
}