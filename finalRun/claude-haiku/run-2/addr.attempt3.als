sig Listing {
}

sig Address extends Listing {
}

sig Name extends Listing {
}

sig Book {
  entry: set Name,
  listed: Name -> lone Listing
}

fact AllListingsAreAddressesOrNames {
  Listing = Address + Name
}

fact AddressAndNameAreDisjoint {
  no Address & Name
}

fun lookup[b: Book, n: Name]: set Listing {
  n.(b.listed^)
}

fact ListedDomainIsEntry {
  all b: Book, n: Name | some b.listed[n] implies n in b.entry
}

fact LookupResultInEntry {
  all b: Book, n: Name | (lookup[b, n] & Name) in b.entry
}

fact NoSelfReferenceInLookup {
  all b: Book, n: b.entry | n not in lookup[b, n]
}