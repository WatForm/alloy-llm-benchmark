abstract sig Listing {}

sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  n.^(b.listed)
}

fact {
  all b: Book, n: b.entry |
    lone n.(b.listed)
}

fact {
  all b: Book, n: Name |
    n in lookup[b, n] implies n in b.entry
}

fact {
  all b: Book |
    no n: b.entry |
      n in lookup[b, n]
}