sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

sig Property {
    influences: set Property,
    state: one QuallitativeState
}

sig QuallitativeState {}
sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

sig ThermalThing extends Thing {}
one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}
one sig Coffee extends Substance {}

sig ThermalProperty extends Property {}
sig HEAT extends ThermalProperty {
    greaterThan: lone HEAT
}
sig TEMPERATURE extends ThermalProperty {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact {
    QuallitativeState = INCREASING + DECREASING + NOCHANGE

    Thing = ThermalThing
    ThermalThing = Substance + Cup
    Substance = Coffee

    Property = ThermalProperty
    ThermalProperty = HEAT + TEMPERATURE
    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP

    Process = HeatFlow
}

fact {
    all t: Thing | t not in t.touches
    touches = ~touches

    all h: HEAT | h not in h.greaterThan
    greaterThan != ~greaterThan
}

fact {
    Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
    Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
    all t: Thing - (Coffee + Cup) | no t.hasProperty

    HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
    HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
    all p: Property - (HEAT_OF_COFFEE + HEAT_OF_CUP) | no p.influences
}

fact {
    all t: ThermalThing |
        no (t.touches & (Cup + Coffee)) implies
            (no greaterThan and no HeatFlow)

    all t: ThermalThing |
        (t.touches in (Cup + Coffee)) iff
            ((HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) or
             (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) or
             (not (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) and
              not (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)))

    all t: ThermalThing |
        ((t.touches in (Cup + Coffee)) and
         not (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) and
         not (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan))
        implies
            (HeatFlow.increases != HEAT_OF_CUP and
             HeatFlow.increases != HEAT_OF_COFFEE and
             HeatFlow.decreases != HEAT_OF_COFFEE and
             HeatFlow.decreases != HEAT_OF_CUP)

    all t: ThermalThing |
        ((t.touches in (Cup + Coffee)) and
         (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan))
        implies
            (HEAT_OF_COFFEE.state = INCREASING and
             TEMPERATURE_OF_COFFEE.state = INCREASING and
             HEAT_OF_CUP.state = DECREASING and
             TEMPERATURE_OF_CUP.state = DECREASING and
             increases.HEAT_OF_COFFEE = HeatFlow and
             decreases.HEAT_OF_CUP = HeatFlow)

    all t: ThermalThing |
        ((t.touches in (Cup + Coffee)) and
         (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan))
        implies
            (HEAT_OF_COFFEE.state = DECREASING and
             TEMPERATURE_OF_COFFEE.state = DECREASING and
             HEAT_OF_CUP.state = INCREASING and
             TEMPERATURE_OF_CUP.state = INCREASING and
             increases.HEAT_OF_CUP = HeatFlow and
             decreases.HEAT_OF_COFFEE = HeatFlow)
}