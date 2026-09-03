sig Target, Book {}

sig Addr extends Target {}
sig Name extends Target {}

fact {
  Addr + Name = Target
}

sig Alias, Group extends Name {}

fact {
  Alias + Group = Name
}

sig Book {
  addr: Name -> Target
}

fact {
  all b: Book | no n: Name | n in n.(b.addr.^(b.addr))
}

fact {
  all b: Book, a: Alias | lone a.(b.addr)
}