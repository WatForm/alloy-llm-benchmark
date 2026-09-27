abstract sig Target {}

sig Addr extends Target {}

abstract sig Name extends Target {}

sig Alias, Group extends Name {}

sig Book {
  addr: Name -> Target
}

fact {
  all b: Book | no n: Name | n in n.^(b.addr)
}

fact {
  all b: Book, a: Alias | lone (a.^(b.addr) & Target)
}