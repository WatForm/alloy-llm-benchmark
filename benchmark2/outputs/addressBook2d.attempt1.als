abstract sig Target {}

sig Addr extends Target {}

abstract sig Name extends Target {}

sig Alias, Group extends Name {}

sig Book {
  addr: Name -> Target
} {
  all n: Name | n not in n.^addr
  all a: Alias | lone a.addr
}