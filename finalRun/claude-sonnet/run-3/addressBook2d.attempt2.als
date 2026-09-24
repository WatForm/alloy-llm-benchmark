abstract sig Target {}

abstract sig Name extends Target {}
sig Addr extends Target {}

sig Alias extends Name {}
sig Group extends Name {}

sig Book {
	addr: Name -> Target
}

fact NoSelfReach {
	all b: Book | no n: Name | n in n.^(b.addr)
}

fact AliasSingleStep {
	all b: Book, a: Alias | lone a.(b.addr)
}