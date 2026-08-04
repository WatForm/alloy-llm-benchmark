sig Event {} 
one sig GraduationCeremony extends Event {} 
one sig TravelingAbroad extends Event {} 
one sig InitiationCeremony extends Event {} 
one sig FlowerViewing extends Event {} 
one sig Hiking extends Event {} 

sig Item {} 
one sig Shoes extends Item {} 
one sig Handkerchief extends Item {} 
one sig Shirt extends Item {} 
one sig Slacks extends Item {} 
one sig Camera extends Item {} 

sig Person { 
    event: Event, 
    item: Item 
} 

one sig Tanaka extends Person { 
    item = Shirt 
} 

one sig Takeuchi extends Person { 
    item = Slacks, 
    event = FlowerViewing 
} 

one sig Ishida extends Person { 
    item: Item, 
    event: Event 
} 

one sig Kasai extends Person { 
    event: Event 
} 

one sig Aoyama extends Person { 
    item: Item 
} 

fact { 
    all p1, p2: Person | 
        p1 != p2 implies p1.event != p2.event 

    all p1, p2: Person | 
        p1 != p2 implies p1.item != p2.item 

    all p: Person | 
        (p.event = InitiationCeremony implies p.item = Shoes) 

    Ishida.item != Shoes 
    Ishida.event != InitiationCeremony 
    Kasai.event != GraduationCeremony 
    Tanaka.event != GraduationCeremony 
    Aoyama.event != GraduationCeremony and Aoyama.event != Hiking 
    Aoyama.item != Shoes and Aoyama.item != Camera 
}