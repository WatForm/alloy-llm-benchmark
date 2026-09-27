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
  // No distinct Persons have the same event
  all p1, p2: Person | p1.event = p2.event implies p1 = p2
  
  // No distinct Persons have the same item
  all p1, p2: Person | p1.item = p2.item implies p1 = p2
  
  // Tanaka's item is Shirt
  Tanaka.item = Shirt
  
  // Takeuchi's item is Slacks
  Takeuchi.item = Slacks
  
  // Takeuchi's event is FlowerViewing
  Takeuchi.event = FlowerViewing
  
  // If a Person's event is InitiationCeremony then that Person's item is Shoes
  all p: Person | p.event = InitiationCeremony implies p.item = Shoes
  
  // Ishida's item is not Shoes
  Ishida.item != Shoes
  
  // Ishida's event is not InitiationCeremony
  Ishida.event != InitiationCeremony
  
  // Kasai's event is not GraduationCeremony
  Kasai.event != GraduationCeremony
  
  // Tanaka's event is not GraduationCeremony
  Tanaka.event != GraduationCeremony
  
  // Aoyama's event is neither GraduationCeremony nor Hiking
  Aoyama.event != GraduationCeremony and Aoyama.event != Hiking
  
  // Aoyama's item is neither Shoes nor Camera
  Aoyama.item != Shoes and Aoyama.item != Camera
}