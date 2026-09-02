abstract sig Listing {}
sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> set Listing
}

fact {
  all b: Book, n: b.entry |
    lone n.(b.listed)
}

fact {
  all b: Book, n, m: Name |
    m in n.^(b.listed) implies m in b.entry
}

fact {
  all b: Book, n: b.entry |
    n not in n.^(b.listed)
}