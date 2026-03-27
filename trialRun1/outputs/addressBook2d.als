abstract sig Target {}

sig Addr extends Target {}

abstract sig Name extends Target {}

sig Alias, Group extends Name {}

sig Book {
  addr: Name -> Target
}

fact {
  all b: Book | no n: Name | n in n.^(b.addr)
  all b: Book | all a: Alias | lone a.(b.addr)
}

pred show(b: Book) {
  some Alias.(b.addr)
}

run show for 1 Book, 3 but 3 Target