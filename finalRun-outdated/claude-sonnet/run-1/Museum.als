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
}

fact PictureAllocation {
  all p: Picture | p in Museum.onDisplay or (some c: Client | p in c.loaned)
}

fact PermanentImpliesOnDisplay {
  Museum.permanent in Museum.onDisplay
}

fact NoOnDisplayLoaned {
  no (Museum.onDisplay & Client.loaned)
}

fact DesiresNotPermanent {
  all c: Client | c.desires != Museum.permanent
}

fact NoDesiresLoanedOverlap {
  all c: Client | no (c.desires & c.loaned)
}

fact DesiresImpliesLoaned {
  all p: Picture | (some c: Client | p in c.desires) implies (some c: Client | p in c.loaned)
}

fact DistinctClientsLoanedDisjoint {
  all disj c1, c2: Client | no (c1.loaned & c2.loaned)
}