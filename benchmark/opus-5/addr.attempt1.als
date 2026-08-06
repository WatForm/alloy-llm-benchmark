abstract sig Listing {}

sig Book {
	entry: set Name,
	listed: entry -> set Listing
}

sig Address extends Listing {}
sig Name extends Listing {}

fun lookup[b: Book, n: Name]: set Listing {
	n.^(b.listed)
}

fact {
	all b: Book, n: b.entry | lone n.(b.listed)
}

fact {
	all b: Book, n: Name | (lookup[b, n] & Name) in b.entry
}

fact {
	all b: Book, n: b.entry | n not in lookup[b, n]
}