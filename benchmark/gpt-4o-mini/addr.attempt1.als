sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
    entry: set Name,
    listed: Name -> set Listing
}

pred Lookup(b: Book, n: Name, result: set Listing) {
    result = { l: Listing | l in b.listed[n] or some n' : Name | n' in b.entry && l in Lookup(b, n') }
}

fact {
    // Every Book and Name in the book's entry has at most one Listing in the listed information
    all b: Book, n: Name | n in b.entry implies #(b.listed[n]) <= 1

    // If a Name is in the resulting from looking up a book and a name, then that name is in that book's entry
    all b: Book, n: Name, r: set Listing | Lookup(b, n, r) implies n in b.entry

    // All names in a book's entry cannot be in the set resulting from looking up that book and the name
    all b: Book | no n: Name | n in b.entry and Lookup(b, n, _)
}