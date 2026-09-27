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

fact EveryPictureDisplayedOrLoaned {
  all p: Picture | p in Museum.onDisplay or p in Client.loaned
}

fact PermanentImpliesOnDisplay {
  Museum.permanent in Museum.onDisplay
}

fact NoOverlapDisplayLoaned {
  no Museum.onDisplay & Client.loaned
}

fact DesiresNotEqualPermanent {
  all c: Client | c.desires != Museum.permanent
}

fact NoOverlapDesiresLoaned {
  all c: Client | no c.desires & c.loaned
}

fact DesiredPicturesAreLoaned {
  all p: Picture | p in Client.desires implies p in Client.loaned
}

fact DistinctClientsNoSharedLoaned {
  all disj c1, c2: Client | no c1.loaned & c2.loaned
}