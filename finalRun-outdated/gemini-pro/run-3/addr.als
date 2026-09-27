abstract sig Listing {}
sig Address extends Listing {}
sig Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> set Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  n.^(b.listed)
}

fact {
  all b: Book, n: b.entry | lone n.(b.listed)
  all b: Book, n1: Name, n2: Name | n2 in lookup[b, n1] implies n2 in b.entry
  all b: Book, n: b.entry | n not in lookup[b, n]
}