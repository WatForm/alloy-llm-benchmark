// COFFEE AND CUP
// BRETT KRIZ

abstract sig Thing{
	touches: one Thing,
	hasProperty: set Property
}

abstract sig Property{
	influences: set Property,
	state: one QuallitativeState
}

abstract sig QuallitativeState{}
one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState{}

sig ThermalThing extends Thing {}
one sig Substance, Cup extends ThermalThing {}
one sig Coffee extends Substance {}


abstract sig Process {
	increases: one HEAT,
	decreases: one HEAT
}
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

sig HEAT extends ThermalProperty{
	greaterThan: lone HEAT
	
}

sig ThermalProperty extends Property {}
sig TEMPERATURE extends ThermalProperty {}
one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

fact {
	no greaterThan & iden
	greaterThan != ~greaterThan

	no touches & iden
	touches = ~touches

	hasProperty = Coffee -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE) + Cup -> (TEMPERATURE_OF_CUP + HEAT_OF_CUP)
	influences = HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE + HEAT_OF_CUP -> TEMPERATURE_OF_CUP
	// No touching, no greaterTHan, no HeatFlow
	// Touching: Coffee > Cup , Cup > coffee, Cup == coffee // SETTING GREATERTHAN <-------------

	//	Touching, but no greaterTHan - > noheatflow
	// Touching & greaterTHan -> make heatflow, change QualitativeStates according

	all t:ThermalThing | t.touches != Cup && t.touches != Coffee => no greaterThan && no HeatFlow
 	all t:ThermalThing | t.touches = Cup || t.touches = Coffee <=> greaterThan = HEAT_OF_COFFEE -> HEAT_OF_CUP || greaterThan = HEAT_OF_CUP -> HEAT_OF_COFFEE || greaterThan != (HEAT_OF_CUP -> HEAT_OF_COFFEE + HEAT_OF_COFFEE -> HEAT_OF_CUP)
	all t:ThermalThing | (t.touches = Cup || t.touches = Coffee) && (greaterThan != (HEAT_OF_CUP -> HEAT_OF_COFFEE + HEAT_OF_COFFEE -> HEAT_OF_CUP)) => increases != (HeatFlow -> HEAT_OF_CUP + HeatFlow -> HEAT_OF_COFFEE) && decreases != (HeatFlow -> HEAT_OF_CUP + HeatFlow -> HEAT_OF_COFFEE)
	all t:ThermalThing | (t.touches = Cup || t.touches = Coffee)  && (greaterThan = HEAT_OF_CUP -> HEAT_OF_COFFEE) => state = (HEAT_OF_COFFEE -> INCREASING + TEMPERATURE_OF_COFFEE -> INCREASING + HEAT_OF_CUP -> DECREASING + TEMPERATURE_OF_CUP -> DECREASING) && increases = HeatFlow -> HEAT_OF_COFFEE && decreases = HeatFlow -> HEAT_OF_CUP
	all t:ThermalThing | (t.touches = Cup || t.touches = Coffee)  && (greaterThan = HEAT_OF_COFFEE -> HEAT_OF_CUP) => state = (HEAT_OF_COFFEE -> DECREASING + TEMPERATURE_OF_COFFEE -> DECREASING + HEAT_OF_CUP -> INCREASING + TEMPERATURE_OF_CUP -> INCREASING) && decreases = HeatFlow -> HEAT_OF_COFFEE && increases = HeatFlow -> HEAT_OF_CUP


//	heatFlow
	

}


pred show{}
run show
