sig Target {}

sig Book {
  addr: Name -> Target
}

sig Addr extends Target {}
sig Name extends Target {}

fact {
  Addr + Name = Target
}

sig Alias extends Name {}
sig Group extends Name {}

fact {
  Alias + Group = Name
}

fact {
  all b: Book | no n: Name | n in n.^(b.addr)
}

fact {
  all b: Book, a: Alias | lone a.(b.addr)
}