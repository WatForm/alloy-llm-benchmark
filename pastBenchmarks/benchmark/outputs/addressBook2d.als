module tour/addressBook2d

abstract sig Target {}
sig Addr extends Target {}
abstract sig Name extends Target {}
sig Alias, Group extends Name {}

sig Book {
  addr: Name -> Target
} {
  no n: Name | n in n.^(addr)
  all a: Alias | lone a.addr
}

pred show {
  some b: Book | some a: Alias | some a.(b.addr)
}

run show for 3 but 1 Book