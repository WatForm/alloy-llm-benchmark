sig Target {}
sig Book {}

sig Addr extends Target {}
sig Name extends Target {}
sig Alias extends Name {}
sig Group extends Name {}

sig Book {
    addr: Name -> Target
}

fact {
    Target = Addr + Name
    Name = Alias + Group
    all b: Book, n: Name | n not in n.^(b.addr)
    all b: Book, a: Alias | lone a.(b.addr)
}