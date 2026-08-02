sig Picture {}

sig Client {
  loaned: set Picture,
  desires: set Picture
}

one sig Museum {
  permanent: set Picture,
  onDisplay: set Picture
}

fact MuseumModel {
  all p: Picture | p in Museum.onDisplay or p in Client.loaned

  Museum.permanent in Museum.onDisplay

  no (Museum.onDisplay & Client.loaned)

  all c: Client | no (c.desires & Museum.permanent)

  all c: Client | no (c.desires & c.loaned)

  all c: Client | c.desires in Client.loaned

  all disj c1, c2: Client | no (c1.loaned & c2.loaned)
}

pred showScenario {
  some Museum.permanent
  some (Museum.onDisplay - Museum.permanent)
  some Client.desires
  some Client.loaned
  some c: Client | some (c.loaned - c.desires)
  some c: Client | some (c.loaned & c.desires)
  some (Client.loaned & Client.desires)
}

run showScenario for exactly 3 Client, exactly 8 Picture