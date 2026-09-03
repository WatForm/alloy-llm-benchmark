sig Picture {}

sig Client {
  loaned: set Picture,
  desires: set Picture
}

one sig Museum {
  permanent: set Picture,
  onDisplay: set Picture
}

fact SomePicture {
  some Picture
}

fact SomeClient {
  some Client
}

fact AllPicturesDisplayedOrLoaned {
  all p: Picture | p in Museum.onDisplay or (some c: Client | p in c.loaned)
}

fact PermanentIsOnDisplay {
  all m: Museum | m.permanent in m.onDisplay
}

fact NoDisplayedAndLoaned {
  all m: Museum, c: Client | no (m.onDisplay & c.loaned)
}

fact DesiresNotPermanent {
  all c: Client, m: Museum | c.desires != m.permanent
}

fact NoDesiredAndLoanedBySameClient {
  all c: Client | no (c.desires & c.loaned)
}

fact DesiredPicturesAreLoaned {
  all p: Picture | (some c: Client | p in c.desires) implies (some c2: Client | p in c2.loaned)
}

fact NoSharedLoans {
  all disj c1, c2: Client | no (c1.loaned & c2.loaned)
}