sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
    entry: set Name,
    listed: Name -> one set Listing
}

fun Lookup(b: Book, n: Name): set Listing {
    if n in b.entry then b.listed[n] + { l: Listing | some n': Name | n' in b.listed[n] && l in Lookup(b, n') } 
    else {}
}

fact {
    // Every Book and Name in the book's entry has at most one Listing in the listed information
    all b: Book, n: Name | n in b.entry implies #(b.listed[n]) <= 1

    // If a Name is in the resulting from looking up a book and a name, then that name is in that book's entry
    all b: Book, n: Name | Lookup(b, n) implies n in b.entry

    // All names in a book's entry cannot be in the set resulting from looking up that book and the name
    all b: Book | no n: Name | n in b.entry and Lookup(b, n) != { }
}