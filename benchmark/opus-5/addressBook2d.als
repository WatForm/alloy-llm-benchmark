sig Target {}
sig Book {
	addr: Name -> Target
}

sig Addr extends Target {}
sig Name extends Target {}

fact {
	Target = Addr + Name
}

sig Alias extends Name {}
sig Group extends Name {}

fact {
	Name = Alias + Group
}

fact acyclic {
	all b: Book | no n: Name | n in n.^(b.addr)
}

fact aliasAtMostOne {
	all b: Book, a: Alias | lone a.(b.addr)
}