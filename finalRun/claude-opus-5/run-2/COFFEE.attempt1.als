abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Property {
	influences: set Property,
	state: one QuallitativeState
}

sig Thing {
	touches: one Thing,
	hasProperty: set Property
}

abstract sig ThermalThing extends Thing {}

fact { Thing = ThermalThing }

one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}

one sig Coffee extends Substance {}

sig ThermalProperty extends Property {}

fact { Property = ThermalProperty }

abstract sig HEAT extends ThermalProperty {
	greaterThan: lone HEAT
}

abstract sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE extends HEAT {}
one sig HEAT_OF_CUP extends HEAT {}

abstract sig Process {
	increases: one HEAT,
	decreases: one HEAT
}

one sig HeatFlow extends Process {}

fact greaterThanIrreflexive {
	no h: HEAT | h in h.greaterThan
}

fact greaterThanNotSymmetric {
	greaterThan != ~greaterThan
}

fact touchesIrreflexive {
	no t: Thing | t in t.touches
}

fact touchesSymmetric {
	touches = ~touches
}

fact properties {
	Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
	Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
	no t: Thing | t not in (Coffee + Cup) and some t.hasProperty
}

fact influencesFact {
	influences = HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE + HEAT_OF_CUP -> TEMPERATURE_OF_CUP
}

fact noContact {
	(some t: ThermalThing | no (t.touches & (Cup + Coffee))) implies
		(no greaterThan and no HeatFlow)
}

fact contactIff {
	(some t: ThermalThing | some (t.touches & (Cup + Coffee))) iff
		(HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
		 or HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
		 or (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
		     and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan))
}

fact equilibrium {
	((some t: ThermalThing | some (t.touches & (Cup + Coffee)))
	 and HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
	 and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan) implies
		(HEAT_OF_CUP not in HeatFlow.increases
		 and HEAT_OF_COFFEE not in HeatFlow.increases
		 and HEAT_OF_COFFEE not in HeatFlow.decreases
		 and HEAT_OF_CUP not in HeatFlow.decreases)
}

fact cupHotter {
	((some t: ThermalThing | some (t.touches & (Cup + Coffee)))
	 and HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) implies
		(HEAT_OF_COFFEE.state = INCREASING
		 and TEMPERATURE_OF_COFFEE.state = INCREASING
		 and HEAT_OF_CUP.state = DECREASING
		 and TEMPERATURE_OF_CUP.state = DECREASING
		 and increases.HEAT_OF_COFFEE = HeatFlow
		 and decreases.HEAT_OF_CUP = HeatFlow)
}

fact coffeeHotter {
	((some t: ThermalThing | some (t.touches & (Cup + Coffee)))
	 and HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) implies
		(HEAT_OF_COFFEE.state = DECREASING
		 and TEMPERATURE_OF_COFFEE.state = DECREASING
		 and HEAT_OF_CUP.state = INCREASING
		 and TEMPERATURE_OF_CUP.state = INCREASING
		 and increases.HEAT_OF_CUP = HeatFlow
		 and decreases.HEAT_OF_COFFEE = HeatFlow)
}