abstract sig Listing {}

sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> set Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  n.(b.listed)
}

fact {
  all b: Book, n: b.entry |
    lone lookup[b, n]
}

fact {
  all b: Book, n: Name, l: lookup[b, n] |
    l in b.entry
}

fact {
  all b: Book, n: b.entry |
    n not in lookup[b, n]
}