sig Target {}
sig Book {
    addr: Name -> Target
}
sig Addr, Name extends Target {}
sig Alias, Group extends Name {}

fact {
    Target = Addr + Name
    Name = Alias + Group
}

fact {
    all b: Book | no n: Name | n in n.^(b.addr)
}

fact {
    all b: Book, a: Alias | lone a.(b.addr)
}