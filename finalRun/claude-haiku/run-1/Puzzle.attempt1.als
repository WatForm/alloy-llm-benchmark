abstract sig Event {}
one sig GraduationCeremony extends Event {}
one sig TravelingAbroad extends Event {}
one sig InitiationCeremony extends Event {}
one sig FlowerViewing extends Event {}
one sig Hiking extends Event {}

abstract sig Item {}
one sig Shoes extends Item {}
one sig Handkerchief extends Item {}
one sig Shirt extends Item {}
one sig Slacks extends Item {}
one sig Camera extends Item {}

abstract sig Person {
    event: one Event,
    item: one Item
}
one sig Tanaka extends Person {}
one sig Takeuchi extends Person {}
one sig Ishida extends Person {}
one sig Kasai extends Person {}
one sig Aoyama extends Person {}

fact {
    all p1, p2: Person | p1.event = p2.event => p1 = p2
}

fact {
    all p1, p2: Person | p1.item = p2.item => p1 = p2
}

fact {
    Tanaka.item = Shirt
}

fact {
    Takeuchi.item = Slacks
}

fact {
    Takeuchi.event = FlowerViewing
}

fact {
    all p: Person | p.event = InitiationCeremony => p.item = Shoes
}

fact {
    Ishida.item != Shoes
}

fact {
    Ishida.event != InitiationCeremony
}

fact {
    Kasai.event != GraduationCeremony
}

fact {
    Tanaka.event != GraduationCeremony
}

fact {
    Aoyama.event != GraduationCeremony and Aoyama.event != Hiking
}

fact {
    Aoyama.item != Shoes and Aoyama.item != Camera
}