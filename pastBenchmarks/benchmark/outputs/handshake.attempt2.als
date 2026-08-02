sig Person {
  spouse: one Person,
  shaken: set Person
}

sig Jocelyn, Hilary extends Person {}

fact HandshakingAndMarriage {
  all p: Person | no ((p + p.spouse) & p.shaken)
  all p, q: Person | q in p.shaken iff p in q.shaken
  all p: Person | p != p.spouse
  all p: Person | p.spouse.spouse = p
  Hilary.spouse = Jocelyn
}

fact DistinctHandshakeCountsExceptJocelyn {
  all disj p, q: Person - Jocelyn | #(p.shaken) != #(q.shaken)
}

pred Puzzle {}

run Puzzle for exactly 10 Person, 5 Int
run Puzzle for exactly 12 Person, 5 Int
run Puzzle for exactly 14 Person, 6 Int
run Puzzle for exactly 16 Person, 6 Int