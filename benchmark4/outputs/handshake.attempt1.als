sig Person {
  spouse: one Person,
  shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
  all p: Person | p not in p.shaken
  all p: Person | p.spouse not in p.shaken
  all p, q: Person | p in q.shaken implies q in p.shaken
  all p, q: Person | p != q and p.spouse = q implies q.spouse = p
  all p, q: Person | p != q implies p.spouse != q.spouse
  all p: Person | p.spouse.spouse = p
  all p: Person | p.spouse != p
  Hilary.spouse = Jocelyn
  all p, q: Person - Jocelyn | p != q implies #(p.shaken) != #(q.shaken)
  all p, q: Person - Jocelyn | p != q implies #(p.shaken) != #(q.shaken)
}