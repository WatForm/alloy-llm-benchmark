sig Target {}
sig Addr extends Target {}
sig Name extends Target {}
sig Alias extends Name {}
sig Group extends Name {}
sig Book {
  addr: Name -> Target
}

fact {
  Addr + Name = Target
  no Addr & Name
}

fact {
  Alias + Group = Name
  no Alias & Group
}

fact {
  all b: Book | no n: Name | n in n.^(b.addr :> Name)
}

fact {
  all b: Book, a: Alias | lone b.addr[a]
}