sig Picture {}
sig Client {
    loaned: set Picture,
    desires: set Picture
}
one sig Museum {
    permanent: set Picture,
    onDisplay: set Picture
}

fact { #Picture >= 1 }

fact { #Client >= 1 }

fact {
    all p: Picture | p in Museum.onDisplay or (p in Client.loaned)
}

fact {
    all p: Picture | p in Museum.permanent implies p in Museum.onDisplay
}

fact {
    no p: Picture | p in Museum.onDisplay and p in Client.loaned
}

fact {
    all c: Client | c.desires != Museum.permanent
}

fact {
    all c: Client | no p: Picture | p in c.desires and p in c.loaned
}

fact {
    all p: Picture | (p in Client.desires) implies (p in Client.loaned)
}

fact {
    all c1, c2: Client | c1 != c2 implies (no p: Picture | p in c1.loaned and p in c2.loaned)
}