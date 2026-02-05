abstract sig Person {
  spouse: lone Person,
  parents: set Person
}

sig Man extends Person {}
sig Woman extends Person {}

one sig Adam extends Man {}
one sig Eve extends Woman {}

fact SexComplete {
  Person = Man + Woman
}

fact Biology {
  all p: Person | p not in p.^parents
}

fact Bible {
  // Every person except Adam and Eve has exactly one mother (a Woman) and one father (a Man)
  all p: Person - (Adam + Eve) |
    one (p.parents & Woman) and one (p.parents & Man) and p.parents = (p.parents & Woman) + (p.parents & Man)

  // Adam and Eve have no parents
  no Adam.parents
  no Eve.parents

  // Adam's spouse is Eve
  Adam.spouse = Eve
}

fact SocialNorms {
  // No one is their own spouse
  all p: Person | p.spouse != p

  // Spouse relation is symmetric
  all p, q: Person | (q in p.spouse) <=> (p in q.spouse)

  // If a man/woman has a spouse, it must be of the opposite sex
  all m: Man | no m.spouse or m.spouse in Woman
  all w: Woman | no w.spouse or w.spouse in Man
}

fact NoIncest {
  // No one may marry a parent or a sibling (someone who shares a parent)
  all p, q: Person |
    (q in p.spouse) implies (
      q not in p.parents and no r: r in p.parents && r in q.parents
    )
}

pred Show {
  some p: Person - Adam - Eve | some p.spouse
}

run Show for 6 Person