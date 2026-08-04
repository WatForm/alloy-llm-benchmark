sig Listing {}

sig Address, Name extends Listing {}

sig Book {
    entry: set Name,
    listed: Name -> set Listing
}

fact {
    Listing = Address + Name
    all b: Book | b.listed in b.entry -> Listing
    all b: Book, n: b.entry | lone b.listed[n]
    all b: Book, n: Name, n2: Name |
        n2 in lookup[b, n] implies n2 in b.entry
    all b: Book, n: b.entry |
        n not in lookup[b, n]
}

fun lookup[b: Book, n: Name]: set Listing {
    n.^(b.listed & (Listing -> Listing))
}