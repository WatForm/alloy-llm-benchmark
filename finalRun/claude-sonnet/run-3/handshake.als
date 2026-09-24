sig Person {
  spouse: one Person,
  shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
  no p: Person | p in p.shaken
  no p: Person | p.spouse in p.shaken
  all p, q: Person | q in p.shaken => p in q.shaken
  all p, q: Person | (p != q and q = p.spouse) => p = q.spouse
  all p, q: Person | p != q => p.spouse != q.spouse
  all p: Person | p.spouse.spouse = p
  no p: Person | p.spouse = p
  Hilary.spouse = Jocelyn
  all p, q: Person | (p != q and p != Jocelyn and q != Jocelyn) => #p.shaken != #q.shaken
  all p, q: Person | (p != q and p != Jocelyn and q != Jocelyn) => #p.shaken != #q.shaken
}