abstract sig Event {}
one sig GraduationCeremony, TravelingAbroad, InitiationCeremony, FlowerViewing, Hiking extends Event {}

abstract sig Item {}
one sig Shoes, Handkerchief, Shirt, Slacks, Camera extends Item {}

abstract sig Person {
  event: one Event,
  item: one Item
}
one sig Tanaka, Takeuchi, Ishida, Kasai, Aoyama extends Person {}

fact {
  all disj p1, p2: Person | p1.event != p2.event
  all disj p1, p2: Person | p1.item != p2.item
}

fact {
  Tanaka.item = Shirt
  Takeuchi.item = Slacks
  Takeuchi.event = FlowerViewing
}

fact {
  all p: Person | p.event = InitiationCeremony implies p.item = Shoes
}

fact {
  Ishida.item != Shoes
  Ishida.event != InitiationCeremony
}

fact {
  Kasai.event != GraduationCeremony
}

fact {
  Tanaka.event != GraduationCeremony
}

fact {
  Aoyama.event != GraduationCeremony
  Aoyama.event != Hiking
}

fact {
  Aoyama.item != Shoes
  Aoyama.item != Camera
}