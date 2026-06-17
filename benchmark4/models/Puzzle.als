abstract sig Event {}
one sig GraduationCeremony extends Event{}
one sig TravelingAbroad extends Event{}
one sig InitiationCeremony extends Event{}
one sig FlowerViewing extends Event{}
one sig Hiking extends Event{}

abstract sig Item{}
one sig Shoes extends Item{}
one sig Handkerchief extends Item{}
one sig Shirt extends Item{}
one sig Slacks extends Item{}
one sig Camera extends Item{}

abstract sig Person{
	event: Event,
	item: Item
}
one sig Tanaka extends Person{}
one sig Takeuchi extends Person{}
one sig Ishida extends Person{}
one sig Kasai extends Person{}
one sig Aoyama extends Person{}

fact{
	all p1, p2: Person | p1 = p2 implies p1.event = p2.event else p1.event != p2.event
	all p1, p2: Person | p1 = p2 implies p1.item = p2.item else p1.item != p2.item
}

fact{
	Tanaka.item in Shirt
}

fact{
	Takeuchi.item in Slacks
	Takeuchi.event in FlowerViewing
}

fact{
	all p:Person | p.event in InitiationCeremony implies p.item in Shoes
	Ishida.item not in Shoes
	Ishida.event not in InitiationCeremony
}

fact{
	Kasai.event not in GraduationCeremony
	Tanaka.event not in GraduationCeremony
}

fact{
	Aoyama.event not in GraduationCeremony + Hiking
	Aoyama.item not in Shoes + Camera
}

