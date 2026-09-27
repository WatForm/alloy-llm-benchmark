abstract sig Listing {}

sig Address, Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> lone Listing
}

fun lookup[b: Book, n: Name] : set Listing {
  n.^(b.listed)
}

fact lookupNamesInEntry {
  all b: Book, n: b.entry |
    (lookup[b, n] & Name) in b.entry
}

fact entryNamesNotInLookup {
  all b: Book, n: b.entry |
    no (lookup[b, n] & b.entry)
}