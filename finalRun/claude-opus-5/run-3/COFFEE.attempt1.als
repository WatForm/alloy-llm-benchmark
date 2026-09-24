abstract sig Thing {
	touches: one Thing,
	hasProperty: set Property
}

abstract sig Property {
	influences: set Property,
	state: one QuallitativeState
}

abstract sig QuallitativeState {}

sig Process {
	increases: one HEAT,
	decreases: one HEAT
}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig ThermalThing extends Thing {}

fact { Thing = ThermalThing }

sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}

fact { one Substance }
fact { ThermalThing = Substance + Cup }

one sig Coffee extends Substance {}

fact { Substance = Coffee }

sig ThermalProperty extends Property {}

fact { Property = ThermalProperty }

sig TEMPERATURE extends ThermalProperty {}

sig HEAT extends ThermalProperty {
	greaterThan: lone HEAT
}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

fact { TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP }

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

fact { HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP }

one sig HeatFlow extends Process {}

fact { Process = HeatFlow }

fact {
	no h: HEAT | h in h.greaterThan
}

fact {
	greaterThan != ~greaterThan
}

fact {
	no t: Thing | t in t.touches
}

fact {
	touches = ~touches
}

fact {
	Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
	Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
	all t: Thing | t not in (Coffee + Cup) implies no t.hasProperty
}

fact {
	influences = HEAT_OF_COFFEE->TEMPERATURE_OF_COFFEE + HEAT_OF_CUP->TEMPERATURE_OF_CUP
}

fact {
	(some t: ThermalThing | no (t.touches & (Cup + Coffee)))
		implies (no greaterThan and no HeatFlow)
}

fact {
	(some t: ThermalThing | some (t.touches & (Cup + Coffee)))
		iff
	(HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
		or HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
		or (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
			and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan))
}

fact {
	((some t: ThermalThing | some (t.touches & (Cup + Coffee)))
		and HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
		and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan)
	implies
	(HEAT_OF_CUP not in HeatFlow.increases
		and HEAT_OF_COFFEE not in HeatFlow.increases
		and HEAT_OF_COFFEE not in HeatFlow.decreases
		and HEAT_OF_CUP not in HeatFlow.decreases)
}

fact {
	((some t: ThermalThing | some (t.touches & (Cup + Coffee)))
		and HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
	implies
	(HEAT_OF_COFFEE.state = INCREASING
		and TEMPERATURE_OF_COFFEE.state = INCREASING
		and HEAT_OF_CUP.state = DECREASING
		and TEMPERATURE_OF_CUP.state = DECREASING
		and increases.HEAT_OF_COFFEE = HeatFlow
		and decreases.HEAT_OF_CUP = HeatFlow)
}

fact {
	((some t: ThermalThing | some (t.touches & (Cup + Coffee)))
		and HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
	implies
	(HEAT_OF_COFFEE.state = DECREASING
		and TEMPERATURE_OF_COFFEE.state = DECREASING
		and HEAT_OF_CUP.state = INCREASING
		and TEMPERATURE_OF_CUP.state = INCREASING
		and increases.HEAT_OF_CUP = HeatFlow
		and decreases.HEAT_OF_COFFEE = HeatFlow)
}