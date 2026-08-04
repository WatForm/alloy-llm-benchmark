sig Target {}
sig Book {}

sig Addr extends Target {}
sig Name extends Target {}
sig Alias, Group extends Name {
}

sig Book {
    addr: Name -> Target
}

fact {
    Target = Addr + Name
    no Addr & Name
    Name = Alias + Group
    no Alias & Group
    all b: Book | no n: Name | n in n.^(b.addr)
    all b: Book, a: Alias | lone a.(b.addr)
}