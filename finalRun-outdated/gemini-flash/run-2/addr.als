abstract sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
	entry: set Name,
	listed: entry -> lone Listing
}

fun lookup [b: Book, n: Name] : set Listing {
	n.^(b.listed)
}

fact {
	all b: Book, n: Name | {
		lookup[b, n] & Name in b.entry
		n not in lookup[b, n]
	}
}