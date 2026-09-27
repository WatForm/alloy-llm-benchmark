abstract sig Listing {}

sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: Name -> set Listing
}

fact {
  all b: Book | b.listed.Listing in b.entry
  all b: Book, n: b.entry | lone n.(b.listed)
  all b: Book, n: Name | (n.^(b.listed) & Name) in b.entry
  all b: Book, n: b.entry | n not in n.^(b.listed)
}