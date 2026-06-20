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
  all p: Picture | p in Museum.onDisplay or p in Client.loaned

  all m: Museum | m.permanent in m.onDisplay

  no Museum.onDisplay & Client.loaned

  all c: Client, m: Museum | c.desires != m.permanent

  all c: Client | no c.desires & c.loaned

  Client.desires in Client.loaned

  all disj c1, c2: Client | no c1.loaned & c2.loaned
}