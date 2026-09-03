abstract sig Target {}

sig Addr extends Target {}

abstract sig Name extends Target {}

sig Alias extends Name {}

sig Group extends Name {}

sig Book {
	addr: Name -> Target
}

fact acyclic {
	all b: Book | no n: Name | n in n.^(b.addr)
}

fact aliasLone {
	all b: Book, a: Alias | lone a.(b.addr)
}