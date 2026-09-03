abstract sig Listing {}
sig Address extends Listing {}
sig Name extends Listing {}

sig Book {
    entry: set Name,
    listed: Name -> Listing
}

fact atMostOneListing {
    all b: Book, n: Name | (n in b.entry) => lone b.listed[n]
}

fun lookup[b: Book, n: Name]: set Listing {
    n.^(b.listed)
}

fact lookupNameInEntry {
    all b: Book, n: Name | {
        (lookup[b, n] & Name) in b.entry
    }
}

fact noNameFromEntry {
    all b: Book, n: Name | (n in b.entry) => {
        n !in lookup[b, n]
    }
}