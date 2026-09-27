some sig Picture {}

some sig Client {
    loaned: set Picture,
    desires: set Picture
}

one sig Museum {
    permanent: set Picture,
    onDisplay: set Picture
}

fact {
    all p: Picture |
        p in Museum.onDisplay or p in Client.loaned

    Museum.permanent in Museum.onDisplay

    no (Museum.onDisplay & Client.loaned)

    all c: Client |
        c.desires != Museum.permanent

    all c: Client |
        no (c.desires & c.loaned)

    all c: Client, p: c.desires |
        some c2: Client | p in c2.loaned

    all disj c1, c2: Client |
        no (c1.loaned & c2.loaned)
}