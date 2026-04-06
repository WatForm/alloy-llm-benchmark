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
  no p: Person | p in p.^(father + mother)
}

fact Terminology {
  all m: Man | m.wife.husband = m
  all w: Woman | w.husband.wife = w
}

fact SocialConvention {
  no ((wife + husband) & (~father + ~mother))
}

pred NoSelfFather {
  no m: Man | m.father = m
}

fun grandpas[p: Person]: set Person {
  Man & p.(father + mother).(father + mother)
}

pred ownGrandpa[p: Person] {
  p in grandpas[p]
}

pred SocialConvention1 {
  no ((wife + husband) & (~father + ~mother))
}

pred SocialConvention2 {
  all m: Man | m not in m.wife.~mother
  all w: Woman | w not in w.husband.~father
}

assert Same {
  SocialConvention1 iff SocialConvention2
}

run NoSelfFather
run { some p: Person | ownGrandpa[p] }
check Same