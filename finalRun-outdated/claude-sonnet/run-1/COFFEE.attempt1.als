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

fact QuallitativeStateExact {
    QuallitativeState = INCREASING + DECREASING + NOCHANGE
}

sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

sig ThermalThing extends Thing {}

fact ThermalThingIsThing {
    ThermalThing = Thing
}

one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}

fact ThermalThingExact {
    ThermalThing = Substance + Cup
}

one sig Coffee extends Substance {}

sig ThermalProperty extends Property {}

fact ThermalPropertyIsProperty {
    ThermalProperty = Property
}

sig HEAT extends ThermalProperty {
    greaterThan: lone HEAT
}

sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

fact TemperatureExact {
    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

fact HeatExact {
    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
}

one sig HeatFlow extends Process {}

fact HeatFlowExact {
    Process = HeatFlow
}

fact TouchesIrreflexive {
    all t: Thing | t not in t.touches
}

fact TouchesSymmetric {
    touches = ~touches
}

fact HasPropertyFacts {
    Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
    Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
    all t: Thing | (t !=