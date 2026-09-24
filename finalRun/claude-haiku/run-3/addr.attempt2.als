abstract sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
  entry: set Name,
  listed: Name -> Listing
}

pred lookupContains[b: Book, n: Name, l: Listing] {
  l in b.listed[n] or
  (some n': Name | n' in b.listed[n] and lookupContains[b, n', l])
}

fact {
  all b: Book, n: Name |
    n in b.entry => lone b.listed[n]

  all b: Book, n: Name, n': Name |
    lookupContains[b, n, n'] => n' in b.entry

  all b: Book, n: Name |
    not lookupContains[b, n, n]
}