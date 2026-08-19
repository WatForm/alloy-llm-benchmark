sig Listing {}

sig Book {
  entry: set Name,
  listed: Name -> Listing
}

sig Address, Name extends Listing {}

fact {
  Listing = Address + Name

  all b: Book |
    b.listed in b.entry -> Listing

  all b: Book, n: b.entry |
    lone n.(b.listed)

  all b: Book, n: Name |
    Name & n.^(b.listed) in b.entry

  all b: Book, n: b.entry |
    n not in n.^(b.listed)
}