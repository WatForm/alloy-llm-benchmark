sig Addr extends Target {}

sig Name extends Target {}

abstract sig Target {}

sig Alias, Group extends Name {}

sig Book {
  addr : Name -> Target
}

fact {
  no Addr & Name
  Target = Addr + Name
  no Alias & Group
  Name = Alias + Group
}

fact {
  all b : Book | all n : Name | n not in n.^ (b.addr)
}

fact {
  all b : Book | all a : Alias | lone a.(b.addr)
}