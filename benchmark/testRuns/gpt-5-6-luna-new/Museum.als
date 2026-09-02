sig Picture {}

sig Client {
    loaned: set Picture,
    desires: set Picture
}

one sig Museum {
    permanent: set Picture,
    onDisplay: set Picture
}

fact {
    some Picture
    some Client

    all p: Picture |
        p in Museum.onDisplay or some c: Client | p in c.loaned

    Museum.permanent in Museum.onDisplay

    all c: Client |
        no (c.loaned & Museum.onDisplay)

    all c: Client |
        c.desires != Museum.permanent

    all c: Client |
        no (c.desires & c.loaned)

    all c: Client, p: c.desires |
        some c2: Client | p in c2.loaned

    all disj c1, c2: Client |
        no (c1.loaned & c2.loaned)
}