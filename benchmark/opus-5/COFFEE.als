sig Thing {
	touches: one Thing,
	hasProperty: set Property
}

sig Property {
	influences: set Property,
	state: one QuallitativeState
}

sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

fact qualitativeStates {
	QuallitativeState = INCREASING + DECREASING + NOCHANGE
}

sig Process {
	increases: one HEAT,
	decreases: one HEAT
}

sig ThermalThing extends Thing {}

one sig Cup extends ThermalThing {}

one sig Substance extends ThermalThing {}

one sig Coffee extends Substance {}

fact thermalThings {
	Thing = ThermalThing
	ThermalThing = Cup + Substance
	Substance = Coffee
}

sig ThermalProperty extends Property {}

fact thermalProperties {
	Property = ThermalProperty
}

sig HEAT extends ThermalProperty {
	greaterThan: lone HEAT
}

sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

fact heatsAndTemperatures {
	TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
	HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
}

one sig HeatFlow extends Process {}

fact processes {
	Process = HeatFlow
}

fact greaterThanProperties {
	no h: HEAT | h in h.greaterThan
	greaterThan != ~greaterThan
}

fact touchesProperties {
	no t: Thing | t in t.touches
	touches = ~touches
}

fact propertiesOfThings {
	hasProperty = Coffee->TEMPERATURE_OF_COFFEE + Coffee->HEAT_OF_COFFEE
	            + Cup->TEMPERATURE_OF_CUP + Cup->HEAT_OF_CUP
}

fact influencesOfProperties {
	influences = HEAT_OF_COFFEE->TEMPERATURE_OF_COFFEE + HEAT_OF_CUP->TEMPERATURE_OF_CUP
}

fact noContact {
	all t: ThermalThing |
		(Cup not in t.touches and Coffee not in t.touches)
			implies (no greaterThan and no HeatFlow)
}

fact contactCondition {
	all t: ThermalThing |
		(Cup in t.touches or Coffee in t.touches)
			iff (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
				or HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
				or (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
					and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan))
}

fact equilibrium {
	all t: ThermalThing |
		((Cup in t.touches or Coffee in t.touches)
			and HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
			and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan)
		implies (HEAT_OF_CUP not in HeatFlow.increases
			and HEAT_OF_COFFEE not in HeatFlow.increases
			and HEAT_OF_COFFEE not in HeatFlow.decreases
			and HEAT_OF_CUP not in HeatFlow.decreases)
}

fact cupHotterThanCoffee {
	all t: ThermalThing |
		((Cup in t.touches or Coffee in t.touches)
			and HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
		implies (HEAT_OF_COFFEE.state = INCREASING
			and TEMPERATURE_OF_COFFEE.state = INCREASING
			and HEAT_OF_CUP.state = DECREASING
			and TEMPERATURE_OF_CUP.state = DECREASING
			and increases.HEAT_OF_COFFEE = HeatFlow
			and decreases.HEAT_OF_CUP = HeatFlow)
}

fact coffeeHotterThanCup {
	all t: ThermalThing |
		((Cup in t.touches or Coffee in t.touches)
			and HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
		implies (HEAT_OF_COFFEE.state = DECREASING
			and TEMPERATURE_OF_COFFEE.state = DECREASING
			and HEAT_OF_CUP.state = INCREASING
			and TEMPERATURE_OF_CUP.state = INCREASING
			and increases.HEAT_OF_CUP = HeatFlow
			and decreases.HEAT_OF_COFFEE = HeatFlow)
}