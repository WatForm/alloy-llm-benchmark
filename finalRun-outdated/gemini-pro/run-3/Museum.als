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
  
  all p: Picture, m: Museum | p in m.permanent implies p in m.onDisplay
  
  no p: Picture | p in Museum.onDisplay and p in Client.loaned
  
  all c: Client | c.desires != Museum.permanent
  
  all c: Client | no p: Picture | p in c.desires and p in c.loaned
  
  all p: Picture | p in Client.desires implies p in Client.loaned
  
  all disj c1, c2: Client | no p: Picture | p in c1.loaned and p in c2.loaned
}