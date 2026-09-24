some sig Picture {}

some sig Client {
  loaned: set Picture,
  desires: set Picture
}

one sig Museum {
  permanent: set Picture,
  onDisplay: set Picture
}

fact allPicturesDisplayedOrLoaned {
  all p: Picture | p in Museum.onDisplay or (some c: Client | p in c.loaned)
}

fact permanentIsOnDisplay {
  all m: Museum | m.permanent in m.onDisplay
}

fact noDisplayedAndLoaned {
  all m: Museum, c: Client | no (m.onDisplay & c.loaned)
}

fact desiresNotPermanent {
  all c: Client | c.desires != Museum.permanent
}

fact noDesiredAndLoanedBySameClient {
  all c: Client | no (c.desires & c.loaned)
}

fact desiredPicturesAreLoaned {
  all p: Picture | (some c: Client | p in c.desires) implies (some c: Client | p in c.loaned)
}

fact noSharedLoans {
  all disj c1, c2: Client | no (c1.loaned & c2.loaned)
}