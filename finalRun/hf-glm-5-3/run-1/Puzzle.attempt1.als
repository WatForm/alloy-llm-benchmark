sig Event {}

sig Item {}

sig Person {}

one sig GraduationCeremony, TravelingAbroad, InitiationCeremony, FlowerViewing, Hiking extends Event {}

one sig Shoes, Handkerchief, Shirt, Slacks, Camera extends Item {}

one sig Tanaka, Takeuchi, Ishida, Kasai, Aoyama extends Person {}

sig Event {}

fact {
  // Each Person has exactly one event and one item
  all p: Person | one p.event
  all p: Person | one p.item

  // No distinct Persons share the same event
  all disj p1, p2: Person | p1.event != p2.event

  // No distinct Persons share the same item
  all disj p1, p2: Person | p1.item != p2.item

  Tanaka.item = Shirt
  Takeuchi.item = Slacks
  Takeuchi.event = FlowerViewing

  all p: Person | p.event = InitiationCeremony implies p.item = Shoes

  Ishida.item != Shoes
  Ishida.event != InitiationCeremony

  Kasai.event != GraduationCeremony

  Tanaka.event != GraduationCeremony

  Aoyama.event != GraduationCeremony and Aoyama.event != Hiking

  Aoyama.item != Shoes and Aoyama.item != Camera
}

run {} for 10