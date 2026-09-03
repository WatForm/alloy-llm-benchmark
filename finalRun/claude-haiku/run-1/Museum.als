sig Picture {}

sig Client {
  loaned: set Picture,
  desires: set Picture
}

sig Museum {
  permanent: set Picture,
  onDisplay: set Picture
}

fact exactlyOneMuseum {
  #Museum = 1
}

fact atLeastOnePicture {
  #Picture >= 1
}

fact atLeastOneClient {
  #Client >= 1
}

fact everyPictureInOnDisplayOrLoaned {
  all p: Picture | 
    (some m: Museum | p in m.onDisplay) or 
    (some c: Client | p in c.loaned)
}

fact permanentImpliesOnDisplay {
  all m: Museum | m.permanent in m.onDisplay
}

fact noOnDisplayAndLoaned {
  all m: Museum, c: Client | m.onDisplay & c.loaned = none
}

fact desireNotEqualPermanent {
  all c: Client, m: Museum | c.desires != m.permanent
}

fact noDesiredAndLoaned {
  all c: Client | c.desires & c.loaned = none
}

fact desiredInSomeLoan {
  all p: Picture | (some c: Client | p in c.desires) implies (some c: Client | p in c.loaned)
}

fact noSharedLoans {
  all c1, c2: Client | c1 != c2 implies c1.loaned & c2.loaned = none
}