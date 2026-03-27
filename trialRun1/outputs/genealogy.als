abstract sig Person {
  spouse: lone Person,
  parents: set Person
}

sig Man, Woman extends Person {}

one sig Adam extends Man {}
one sig Eve extends Woman {}

fact Biology {
  no p: Person | p in p.^parents
}

fact Bible {
  all p: Person - Adam - Eve | one (p.parents & Man) and one (p.parents & Woman)
  no Adam.parents
  no Eve.parents
  Adam.spouse = Eve
}

fact SocialNorms {
  no p: Person | p.spouse = p
  spouse = ~spouse
  spouse in (Man -> Woman) + (Woman -> Man)
}

fact NoIncest {
  no p: Person | p.spouse in p.parents
  no p: Person | p.spouse in { s: Person | some (s.parents & p.parents) }
}

pred Show {
  some p: Person - Adam - Eve | some p.spouse
}

run Show for 3 expect 0