sig Target {}

sig Addr extends Target {}
sig Name extends Target {}

sig Alias extends Name {}
sig Group extends Name {}

sig Book {
  addr: Name -> Target
}

fact { Addr + Name = Target }
fact { no Addr & Name }
fact { Alias + Group = Name }
fact { no Alias & Group }

fact {
  all b: Book | no n: Name | n in n.^(b.addr)
}

fact {
  all b: Book, a: Alias | lone b.addr[a]
}