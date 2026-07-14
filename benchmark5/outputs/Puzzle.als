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
  all disj p, q: Person | p.event != q.event
  all disj p, q: Person | p.item != q.item

  Tanaka.item = Shirt
  Takeuchi.item = Slacks
  Takeuchi.event = FlowerViewing

  all p: Person | p.event = InitiationCeremony implies p.item = Shoes

  Ishida.item != Shoes
  Ishida.event != InitiationCeremony

  Kasai.event != GraduationCeremony

  Tanaka.event != GraduationCeremony

  Aoyama.event not in GraduationCeremony + Hiking

  Aoyama.item not in Shoes + Camera
}