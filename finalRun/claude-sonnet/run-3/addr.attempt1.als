abstract sig Listing {}
sig Address extends Listing {}
sig Name extends Listing {}

sig Book {
  entry: set Name,
  listed: entry -> set Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  n.^(b.listed)
}

fact AtMostOneListingPerEntry {
  all b: Book, n: b.entry | lone n.(b.listed)
}

fact LookupResultsAreEntries {
  all b: Book, n: Name, m: Name | m in lookup[b, n] implies m in b.entry
}

fact NoEntryNameInLookup {
  all b: Book, n: b.entry | no (b.entry & lookup[b, n])
}