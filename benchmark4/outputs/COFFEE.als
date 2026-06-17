abstract sig Thing {
	touches: one Thing,
	hasProperty: set Property
}

abstract sig ThermalThing extends Thing {}

one sig Substance extends ThermalThing {}

one sig Cup extends ThermalThing {}

one sig Coffee in Substance {}

abstract sig Property {
	influences: set Property,
	state: one QuallitativeState
}

sig ThermalProperty extends Property {}

sig HEAT in ThermalProperty {
	greaterThan: lone HEAT
}

sig TEMPERATURE in ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE in TEMPERATURE {}

one sig TEMPERATURE_OF_CUP in TEMPERATURE {}

one sig HEAT_OF_COFFEE in HEAT {}

one sig HEAT_OF_CUP in HEAT {}

abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Process {
	increases: one HEAT,
	decreases: one HEAT
}

one sig HeatFlow in Process {}

fact {
	Thing = ThermalThing
	ThermalThing = Substance + Cup
	Coffee = Substance

	ThermalProperty = Property
	no (HEAT & TEMPERATURE)

	TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
	TEMPERATURE_OF_COFFEE != TEMPERATURE_OF_CUP

	HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
}

fact {
	no (iden & greaterThan)
	greaterThan != ~greaterThan

	no (iden & touches)
	touches = ~touches
}

fact {
	hasProperty =
		Coffee->(TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE) +
		Cup->(TEMPERATURE_OF_CUP + HEAT_OF_CUP)

	influences =
		HEAT_OF_COFFEE->TEMPERATURE_OF_COFFEE +
		HEAT_OF_CUP->TEMPERATURE_OF_CUP
}

fact {
	all t: ThermalThing |
		((not (Cup in t.touches)) and (not (Coffee in t.touches))) =>
			(no greaterThan and no HeatFlow)
}

fact {
	all t: ThermalThing |
		(((Cup in t.touches) or (Coffee in t.touches)) <=>
			((HEAT_OF_COFFEE->HEAT_OF_CUP in greaterThan) or
			 (HEAT_OF_CUP->HEAT_OF_COFFEE in greaterThan) or
			 ((not (HEAT_OF_CUP->HEAT_OF_COFFEE in greaterThan)) and
			  (not (HEAT_OF_COFFEE->HEAT_OF_CUP in greaterThan)))))
}

fact {
	all t: ThermalThing |
		(((Cup in t.touches) or (Coffee in t.touches)) and
		 (not (HEAT_OF_CUP->HEAT_OF_COFFEE in greaterThan)) and
		 (not (HEAT_OF_COFFEE->HEAT_OF_CUP in greaterThan))) =>
			((not (HEAT_OF_CUP in HeatFlow.increases)) and
			 (not (HEAT_OF_COFFEE in HeatFlow.increases)) and
			 (not (HEAT_OF_COFFEE in HeatFlow.decreases)) and
			 (not (HEAT_OF_CUP in HeatFlow.decreases)))
}

fact {
	all t: ThermalThing |
		(((Cup in t.touches) or (Coffee in t.touches)) and
		 (HEAT_OF_CUP->HEAT_OF_COFFEE in greaterThan)) =>
			(HEAT_OF_COFFEE.state = INCREASING and
			 TEMPERATURE_OF_COFFEE.state = INCREASING and
			 HEAT_OF_CUP.state = DECREASING and
			 TEMPERATURE_OF_CUP.state = DECREASING and
			 increases.HEAT_OF_COFFEE = HeatFlow and
			 decreases.HEAT_OF_CUP = HeatFlow)
}

fact {
	all t: ThermalThing |
		(((Cup in t.touches) or (Coffee in t.touches)) and
		 (HEAT_OF_COFFEE->HEAT_OF_CUP in greaterThan)) =>
			(HEAT_OF_COFFEE.state = DECREASING and
			 TEMPERATURE_OF_COFFEE.state = DECREASING and
			 HEAT_OF_CUP.state = INCREASING and
			 TEMPERATURE_OF_CUP.state = INCREASING and
			 increases.HEAT_OF_CUP = HeatFlow and
			 decreases.HEAT_OF_COFFEE = HeatFlow)
}