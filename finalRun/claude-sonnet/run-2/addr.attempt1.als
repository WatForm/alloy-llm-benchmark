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

fact ListedAtMostOne {
    all b: Book, n: b.entry | lone n.(b.listed)
}

fact LookupNamesInEntry {
    all b: Book, n: Name | (lookup[b, n] & Name) in b.entry
}

fact NoEntryNameInLookup {
    all b: Book, n: b.entry | no (lookup[b, n] & b.entry)
}