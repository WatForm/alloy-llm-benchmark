sig Target {}
sig Book {
    addr: Name -> Target
}
sig Addr, Name extends Target {}
sig Alias, Group extends Name {}

fact {
    Target = Addr + Name
    Name = Alias + Group
    all b: Book | no n: Name | n in n.^(b.addr)
    all b: Book, a: Alias | lone a.(b.addr)
}