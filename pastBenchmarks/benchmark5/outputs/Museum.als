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
  Picture = Museum.onDisplay + Client.loaned

  Museum.permanent in Museum.onDisplay

  no Museum.onDisplay & Client.loaned

  all c: Client | c.desires != Museum.permanent

  all c: Client | no c.desires & c.loaned

  Client.desires in Client.loaned

  all disj c1, c2: Client | no c1.loaned & c2.loaned
}