abstract sig Listing {}
sig Address extends Listing {}
sig Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> set Listing
}

fact {
  all b: Book, n: b.entry | lone n.(b.listed)
  all b: Book, n: Name | (n.^(b.listed) & Name) in b.entry
  all b: Book, n: b.entry | n not in n.^(b.listed)
}