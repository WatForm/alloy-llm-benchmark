abstract sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
	entry: set Name,
	listed: entry -> Listing
}

fun lookup[b: Book, n: Name]: set Listing {
	n.^(b.listed)
}

fact atMostOneListingPerName {
	all b: Book, n: b.entry | lone n.(b.listed)
}

fact lookupNameImpliesEntry {
	all b: Book, n: Name, n2: Name | n2 in lookup[b, n] implies n2 in b.entry
}

fact noSelfLookup {
	all b: Book, n: b.entry | n not in lookup[b, n]
}