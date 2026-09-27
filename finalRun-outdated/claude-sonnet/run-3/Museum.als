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

  all p: Picture | p in Museum.onDisplay or (some c: Client | p in c.loaned)

  Museum.permanent in Museum.onDisplay

  no Museum.onDisplay & Client.loaned

  all c: Client | c.desires != Museum.permanent

  all c: Client | no (c.desires & c.loaned)

  all p: Picture | (some c: Client | p in c.desires) implies (some c: Client | p in c.loaned)

  all c1, c2: Client | c1 != c2 implies no (c1.loaned & c2.loaned)
}