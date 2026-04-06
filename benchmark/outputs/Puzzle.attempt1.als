abstract sig Event {}
one sig GraduationCeremony, TravelingAbroad, InitiationCeremony, FlowerViewing, Hiking extends Event {}

abstract sig Item {}
one sig Shoes, Handkerchief, Shirt, Slacks, Camera extends Item {}

abstract sig Person {
	event: one Event,
	item: one Item
}
one sig Tanaka, Takeuchi, Ishida, Kasai, Aoyama extends Person {}

fact DifferentEventsAndItems {
	all disj p1, p2: Person {
		p1.event != p2.event
		p1.item != p2.item
	}
}

fact PersonConstraints {
	Tanaka.item = Shirt

	Takeuchi.item = Slacks
	Takeuchi.event = FlowerViewing

	one p: Person | p.event = InitiationCeremony and p.item = Shoes
	Ishida.item != Shoes
	Ishida.event != InitiationCeremony

	Kasai.event != GraduationCeremony
	Tanaka.event != GraduationCeremony

	Aoyama.event != GraduationCeremony
	Aoyama.event != Hiking
	Aoyama.item != Shoes
	Aoyama.item != Camera
}

pred show {}

run show for exactly 5 Person, exactly 5 Event, exactly 5 Item