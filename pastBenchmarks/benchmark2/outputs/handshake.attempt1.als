sig Person {
  spouse: one Person,
  shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact ShakingProtocol {
  all p: Person | p not in p.shaken and p.spouse not in p.shaken
  all p, q: Person | q in p.shaken implies p in q.shaken
}

fact Spouses {
  all p: Person | p.spouse.spouse = p and p != p.spouse
}

fact Puzzle {
  all disj p, q: Person - Jocelyn | #p.shaken != #q.shaken
  Hilary.spouse = Jocelyn
}