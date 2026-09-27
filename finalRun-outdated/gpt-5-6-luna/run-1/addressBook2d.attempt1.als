sig Target {}
sig Book {}

sig Addr, Name extends Target {}
sig Alias, Group extends Name {
}

sig Book {
	addr: Name -> Target
}

fact Partition {
	Target = Addr + Name
	Name = Alias + Group
}

fact Acyclic {
	all b: Book | no n: Name | n in n.^(b.addr)
}

fact AliasAtMostOne {
	all b: Book, a: Alias | lone a.(b.addr)
}