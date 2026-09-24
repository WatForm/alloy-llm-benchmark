abstract sig Event {}
one sig GraduationCeremony, TravelingAbroad, InitiationCeremony, FlowerViewing, Hiking extends Event {}

abstract sig Item {}
one sig Shoes, Handkerchief, Shirt, Slacks, Camera extends Item {}

abstract sig Person {
  event: one Event,
  item: one Item
}

one sig Tanaka, Takeuchi, Ishida, Kasai, Aoyama extends Person {}

// No distinct Persons have the same event
fact {
  all p1, p2: Person | p1.event = p2.event implies p1 = p2
}

// No distinct Persons have the same item
fact {
  all p1, p2: Person | p1.item = p2.item implies p1 = p2
}

// Tanaka's item is Shirt
fact {
  Tanaka.item = Shirt
}

// Takeuchi's item is Slacks
fact {
  Takeuchi.item = Slacks
}

// Takeuchi's event is FlowerViewing
fact {
  Takeuchi.event = FlowerViewing
}

// If a Person's event is InitiationCeremony then that Person's item is Shoes
fact {
  all p: Person | p.event = InitiationCeremony implies p.item = Shoes
}

// Ishida's item is not Shoes
fact {
  Ishida.item != Shoes
}

// Ishida's event is not InitiationCeremony
fact {
  Ishida.event != InitiationCeremony
}

// Kasai's event is not GraduationCeremony
fact {
  Kasai.event != GraduationCeremony
}

// Tanaka's event is not GraduationCeremony
fact {
  Tanaka.event != GraduationCeremony
}

// Aoyama's event is neither GraduationCeremony nor Hiking
fact {
  Aoyama.event != GraduationCeremony and Aoyama.event != Hiking
}

// Aoyama's item is neither Shoes nor Camera
fact {
  Aoyama.item != Shoes and Aoyama.item != Camera
}