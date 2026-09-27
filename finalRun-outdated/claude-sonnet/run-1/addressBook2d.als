abstract sig Target {}

sig Addr extends Target {}
sig Name extends Target {}

fact TargetPartition {
  Addr + Name = Target
}

sig Alias extends Name {}
sig Group extends Name {}

fact NamePartition {
  Alias + Group = Name
}

sig Book {
  addr: Name -> Target
}

fact NoSelfReach {
  all b: Book | no n: Name | n in n.^(b.addr)
}

fact AliasSingleTarget {
  all b: Book, a: Alias | lone a.(b.addr)
}