abstract sig Event {}
one sig GraduationCeremony, TravelingAbroad, InitiationCeremony, FlowerViewing, Hiking extends Event {}

abstract sig Item {}
one sig Shoes, Handkerchief, Shirt, Slacks, Camera extends Item {}

sig Person {
  event: one Event,
  item: one Item
}

one sig Tanaka, Takeuchi, Ishida, Kasai, Aoyama extends Person {}

fact {
  all p, q: Person |
    (p = q) implies (p.event = q.event and p.item = q.item)
  all p, q: Person |
    (p != q) implies (p.event != q.event and p.item != q.item)

  Tanaka.item = Shirt

  Takeuchi.item = Slacks
  Takeuchi.event = FlowerViewing

  all p: Person | p.event = InitiationCeremony implies p.item = Shoes

  Ishida.item != Shoes
  Ishida.event != InitiationCeremony

  Kasai.event != GraduationCeremony
  Tanaka.event != GraduationCeremony

  Aoyama.event != GraduationCeremony
  Aoyama.event != Hiking
  Aoyama.item != Shoes
  Aoyama.item != Camera
}

run {} for exactly 5 Event, exactly 5 Item, exactly 5 Person