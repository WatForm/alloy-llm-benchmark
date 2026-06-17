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
}

fact {
  Museum.permanent in Museum.onDisplay
}

fact {
  no Museum.onDisplay & Client.loaned
}

fact {
  all c: Client | c.desires != Museum.permanent
}

fact {
  all c: Client | no c.desires & c.loaned
}

fact {
  Client.desires in Client.loaned
}

fact {
  all disj c1, c2: Client | no c1.loaned & c2.loaned
}