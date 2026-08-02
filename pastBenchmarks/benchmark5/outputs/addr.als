abstract sig Listing {}

sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: Name -> lone Listing
}

fact {
  all b: Book | b.listed in b.entry -> Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  n.^(b.listed)
}

fact {
  all b: Book, n: Name | (lookup[b, n] & Name) in b.entry
}

fact {
  all b: Book, n: b.entry | n not in lookup[b, n]
}