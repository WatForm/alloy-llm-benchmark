abstract sig Target {}
abstract sig Name extends Target {}
sig Addr extends Target {}
sig Alias, Group extends Name {}
sig Book {
    addr: Name -> Target
}

fact {
    no b: Book | some n: Name & ^(b.addr)
    all b: Book, a: Alias | lone a.(b.addr)
}