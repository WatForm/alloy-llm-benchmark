abstract sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> set Listing
}

fact {
  all b: Book, n: b.entry | lone n.(b.listed)
  all b: Book, n1, n2: Name | n2 in n1.^(b.listed) implies n2 in b.entry
  all b: Book, n: b.entry | n not in n.^(b.listed)
}