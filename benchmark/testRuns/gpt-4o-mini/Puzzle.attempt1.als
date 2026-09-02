sig Event {} 
sig GraduationCeremony extends Event {} 
sig TravelingAbroad extends Event {} 
sig InitiationCeremony extends Event {} 
sig FlowerViewing extends Event {} 
sig Hiking extends Event {} 

sig Item {}
sig Shoes extends Item {} 
sig Handkerchief extends Item {} 
sig Shirt extends Item {} 
sig Slacks extends Item {} 
sig Camera extends Item {} 

sig Person {} 
sig Tanaka extends Person {} 
sig Takeuchi extends Person {} 
sig Ishida extends Person {} 
sig Kasai extends Person {} 
sig Aoyama extends Person {} 

one sig event: Event | Person { 
    Tanaka.event = Ishida.event || Kasai.event || Takeuchi.event || Aoyama.event  
}

one sig item: Item | Person {
    Tanaka.item = Shirt 
    Takeuchi.item = Slacks 
    Takeuchi.event = FlowerViewing 
    Ishida.item != Shoes 
    Ishida.event != InitiationCeremony 
    Kasai.event != GraduationCeremony 
    Tanaka.event != GraduationCeremony 
    Aoyama.event != GraduationCeremony && Aoyama.event != Hiking 
    Aoyama.item != Shoes && Aoyama.item != Camera 
}

fact {
    all p1, p2: Person | p1 != p2 implies p1.event != p2.event
    all p1, p2: Person | p1 != p2 implies p1.item != p2.item
    all p: Person | (p.event = InitiationCeremony implies p.item = Shoes) 
}