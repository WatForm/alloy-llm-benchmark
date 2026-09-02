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

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact {
    QuallitativeState = INCREASING + DECREASING + NOCHANGE

    Thing = ThermalThing
    ThermalThing = Substance + Cup
    Substance = Coffee

    ThermalProperty = Property

    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP

    Process = HeatFlow

    no iden & touches
    touches = ~touches

    no iden & greaterThan
    greaterThan != ~greaterThan

    hasProperty =
        Coffee -> TEMPERATURE_OF_COFFEE +
        Coffee -> HEAT_OF_COFFEE +
        Cup -> TEMPERATURE_OF_CUP +
        Cup -> HEAT_OF_CUP

    influences =
        HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE +
        HEAT_OF_CUP -> TEMPERATURE_OF_CUP

    all t: ThermalThing |
        ((Cup in t.touches or Coffee in t.touches) iff
            (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan or
             HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan or
             (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and
              HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan)))

    all t: ThermalThing |
        (Cup not in t.touches and Coffee not in t.touches) implies
            (no greaterThan and no HeatFlow)

    all t: ThermalThing |
        ((Cup in t.touches or Coffee in t.touches) and
         HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and
         HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan) implies
            (HEAT_OF_CUP not in HeatFlow.increases and
             HEAT_OF_COFFEE not in HeatFlow.increases and
             HEAT_OF_COFFEE not in HeatFlow.decreases and
             HEAT_OF_CUP not in HeatFlow.decreases)

    all t: ThermalThing |
        ((Cup in t.touches or Coffee in t.touches) and
         HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) implies
            (HEAT_OF_COFFEE.state = INCREASING and
             TEMPERATURE_OF_COFFEE.state = INCREASING and
             HEAT_OF_CUP.state = DECREASING and
             TEMPERATURE_OF_CUP.state = DECREASING and
             HeatFlow.increases = HEAT_OF_COFFEE and
             HeatFlow.decreases = HEAT_OF_CUP)

    all t: ThermalThing |
        ((Cup in t.touches or Coffee in t.touches) and
         HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) implies
            (HEAT_OF_COFFEE.state = DECREASING and
             TEMPERATURE_OF_COFFEE.state = DECREASING and
             HEAT_OF_CUP.state = INCREASING and
             TEMPERATURE_OF_CUP.state = INCREASING and
             HeatFlow.increases = HEAT_OF_CUP and
             HeatFlow.decreases = HEAT_OF_COFFEE)
}