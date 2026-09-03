abstract sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
	entry: set Name,
	listed: entry -> some Listing
}

fun lookup [b: Book, n: Name] : set Listing {
	n.^(b.listed)
}

fact {
	all b: Book, n: b.entry | lone n.(b.listed)
}

fact {
	all b: Book, n: Name | Name & lookup[b, n] in b.entry
}

fact {
	all b: Book, n: b.entry | n not in lookup[b, n]
}