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
  no p: Person | p in p.^(father + mother)
}

fact Terminology {
  wife = ~husband
}

fact SocialConvention {
  no p: Person | some p.wife implies p.wife in p.^(father + mother)
  no p: Woman | some p.husband implies p.husband in p.^(father + mother)
}