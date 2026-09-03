sig Person {
  spouse: one Person,
  shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact NoSelfOrSpouseShaken {
  no p: Person | p in p.shaken
  no p: Person | p.spouse in p.shaken
}

fact SymmetricShaken {
  all p, q: Person | p in q.shaken => q in p.shaken
}

fact SymmetricSpouse {
  all p, q: Person | (p != q and p.spouse = q) => q.spouse = p
}

fact DistinctSpouses {
  all p, q: Person | p != q => p.spouse != q.spouse
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
  all p, q: Person | (p != q and p != Jocelyn and q != Jocelyn) => #p.shaken != #q.shaken
}