abstract sig Listing {}

sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: Name -> Listing
}

fact {
  all b: Book | b.listed in b.entry -> Listing
}

fact {
  all b: Book, n: b.entry | lone n.(b.listed)
}

fact {
  all b: Book, n: Name | (n.^(b.listed) & Name) in b.entry
}

fact {
  all b: Book, n: b.entry | n not in n.^(b.listed)
}