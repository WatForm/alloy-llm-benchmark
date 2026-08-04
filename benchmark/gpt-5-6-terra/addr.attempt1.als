abstract sig Listing {}

sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> set Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  n.^(b.listed)
}

fact {
  all b: Book, n: b.entry | lone n.(b.listed)
  all b: Book, n: Name | (lookup[b, n] & Name) in b.entry
  all b: Book, n: b.entry | n not in lookup[b, n]
}