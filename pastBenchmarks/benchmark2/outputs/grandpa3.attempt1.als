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
  no p: Person | p in p.^(mother + father)
}

fact Terminology {
  wife = ~husband
}

fact SocialConvention {
  no p: Person | p.(mother + father) & (p.(wife + husband))
}