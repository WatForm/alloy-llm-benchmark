abstract sig Listing {}

sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> lone Listing
}

fact {
  all b: Book, n: Name |
    (n.^(b.listed) & Name) in b.entry
}

fact {
  all b: Book, n: b.entry |
    n not in n.^(b.listed)
}