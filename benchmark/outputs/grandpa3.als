sig Person {
  father: lone Man,
  mother: lone Woman
}

sig Man extends Person {
  wife: lone Woman
}

sig Woman extends Person {
  husband: lone Man
}

fact Biology {
  no p: Person | p in p.^(mother + father)
}

fact Terminology {
  wife = ~husband
}

fact SocialConvention {
  no ((mother + father + ^(mother + father)) & (wife + husband))
}

assert NoSelfFather {
  no m: Man | m.father = m
}

fun grandpas[p: Person]: set Person {
  p.(mother + father).(mother + father) +
  p.mother.mother.husband +
  p.mother.father.wife +
  p.father.mother.husband +
  p.father.father.wife
}

pred ownGrandpa {
  some p: Person | p in grandpas[p]
}

check NoSelfFather for 4 Person
run ownGrandpa for 4 Person

pred SocialConvention1 {
  no ((mother + father + ^(mother + father)) & (wife + husband))
}

pred SocialConvention2 {
  no m: Man | m.wife in m.^(mother + father)
  no w: Woman | w.husband in w.^(mother + father)
}

assert Same {
  SocialConvention1 iff SocialConvention2
}

check Same for 4 Person