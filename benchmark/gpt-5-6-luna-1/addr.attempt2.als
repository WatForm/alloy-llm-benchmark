sig Listing {}

sig Book {
    entry: set Name,
    listed: Name -> set Listing
}

sig Address, Name extends Listing {}

fact {
    Listing = Address + Name
    all b: Book | b.listed in b.entry -> Listing
    all b: Book | all n: b.entry | lone b.listed[n]
    all b: Book | all n: Name |
        (n.^(b.listed) & Name) in b.entry
    all b: Book | all n: b.entry |
        no (n & n.^(b.listed))
}