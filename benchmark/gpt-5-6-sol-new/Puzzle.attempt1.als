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
    all disj p1, p2: Person | p1.event != p2.event
    all disj p1, p2: Person | p1.item != p2.item

    Tanaka.item = Shirt
    Takeuchi.item = Slacks
    Takeuchi.event = FlowerViewing

    all p: Person |
        p.event = InitiationCeremony implies p.item = Shoes

    Ishida.item != Shoes
    Ishida.event != InitiationCeremony

    Kasai.event != GraduationCeremony
    Tanaka.event != GraduationCeremony

    Aoyama.event != GraduationCeremony
    Aoyama.event != Hiking

    Aoyama.item != Shoes
    Aoyama.item != Camera
}