abstract sig Listing {}

sig Address extends Listing {}
sig Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  n.(b.listed)
}

fact {
  all b: Book, n: b.entry |
    lone lookup[b, n]
}

fact {
  all b: Book, n: b.entry, l: Listing |
    l in lookup[b, n] implies l in b.entry
}

fact {
  all b: Book, n: b.entry |
    n not in lookup[b, n]
}

assert lookupEndsInAddr {
  all b: Book, n: b.entry |
    some (lookup[b, n] & Address)
}

check lookupEndsInAddr for 4