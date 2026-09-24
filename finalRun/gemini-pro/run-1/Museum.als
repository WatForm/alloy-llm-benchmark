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
  all m: Museum, p: m.permanent | p in m.onDisplay
  no p: Picture | p in Museum.onDisplay and p in Client.loaned
  all c: Client | c.desires != Museum.permanent
  all c: Client | no c.desires & c.loaned
  all p: Client.desires | p in Client.loaned
  all disj c1, c2: Client | no c1.loaned & c2.loaned
}