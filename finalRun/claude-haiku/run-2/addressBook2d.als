abstract sig Target {}
sig Addr extends Target {}
abstract sig Name extends Target {}
sig Alias extends Name {}
sig Group extends Name {}

sig Book {
  addr: Name -> Target
}

fact {
  all b: Book |
    let rel = b.addr :> Name |
      no n: Name | n in n.^rel
}

fact {
  all b: Book, a: Alias |
    lone b.addr[a]
}