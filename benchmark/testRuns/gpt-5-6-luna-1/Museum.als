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
        p in Museum.onDisplay or p in Client.loaned

    all m: Museum |
        m.permanent in m.onDisplay

    no (Museum.onDisplay & Client.loaned)

    all c: Client |
        c.desires != Museum.permanent

    all c: Client |
        no (c.desires & c.loaned)

    all p: Client.desires |
        some c: Client | p in c.loaned

    all disj c1, c2: Client |
        no (c1.loaned & c2.loaned)
}