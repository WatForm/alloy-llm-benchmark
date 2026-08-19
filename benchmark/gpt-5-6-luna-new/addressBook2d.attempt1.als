sig Target {}

sig Book {
    addr: Name -> Target
}

sig Addr in Target {}

sig Name in Target {}

sig Alias in Name {}

sig Group in Name {}

fact {
    Target = Addr + Name
    no Addr & Name
    Name = Alias + Group
    no Alias & Group
}

fact {
    all b: Book |
        no n: Name | n in n.^(b.addr)
}

fact {
    all b: Book, a: Alias |
        lone a.(b.addr)
}