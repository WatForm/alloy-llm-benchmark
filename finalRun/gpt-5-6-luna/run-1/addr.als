sig Listing {}

sig Address, Name in Listing {}

sig Book {
    entry: set Name,
    listed: Name -> Listing
}

fact {
    Listing = Address + Name
    no Address & Name

    all b: Book |
        b.listed in b.entry -> Listing

    all b: Book, n: b.entry |
        lone n.(b.listed)

    all b: Book, start: Name |
        (start.^(b.listed) & Name) in b.entry

    all b: Book, start: Name |
        no (b.entry & start.^(b.listed))
}