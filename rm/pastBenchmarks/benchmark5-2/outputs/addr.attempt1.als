abstract sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
  entry: set Name,
  listed: Name -> set Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  n.^(b.listed)
}

fact {
  all b: Book | b.listed in (b.entry -> Listing)

  all b: Book, n: b.entry | lone n.(b.listed)

  all b: Book, n: Name | (lookup[b, n] & Name) in b.entry

  all b: Book, n: b.entry | n not in lookup[b, n]
}