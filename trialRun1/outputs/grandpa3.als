abstract sig Person {
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
  no p: Person | p in p.(mother + father)
}

fact Terminology {
  wife = ~husband
}

fact SocialConvention {
  no ((Man.wife + Woman.husband) & (Person.mother + Person.father))
}

assert NoSelfFather {
  no m: Man | m = m.father
}

fun grandpas[p: Person]: set Person {
  p.mother.father + p.father.father + p.mother.husband.father + p.father.wife.father
}

pred ownGrandpa[p: Person] {
  p in grandpas[p]
}

pred SocialConvention1 {
  no ((Man.wife + Woman.husband) & (Person.mother + Person.father))
}

pred SocialConvention2 {
  no m: Man | m.wife = m.mother
  no w: Woman | w.husband = w.father
}

assert Same {
  SocialConvention1 iff SocialConvention2
}

check NoSelfFather
check Same