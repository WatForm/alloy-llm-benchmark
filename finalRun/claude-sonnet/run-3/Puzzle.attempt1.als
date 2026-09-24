abstract sig Event {}
one sig GraduationCeremony, TravelingAbroad, InitiationCeremony, FlowerViewing, Hiking extends Event {}

abstract sig Item {}
one sig Shoes, Handkerchief, Shirt, Slacks, Camera extends Item {}

abstract sig Person {
  event: one Event,
  item: one Item
}
one sig Tanaka, Takeuchi, Ishida, Kasai, Aoyama extends Person {}

fact NoSharedEvent {
  all disj p1, p2: Person | p1.event != p2.event
}

fact NoSharedItem {
  all disj p1, p2: Person | p1.item != p2.item
}

fact Constraints {
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