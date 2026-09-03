sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

sig Property {
    influences: set Property,
    state: one QuallitativeState
}

sig QuallitativeState {}

sig ThermalThing extends Thing {}

sig ThermalProperty extends Property {}

sig HEAT extends ThermalProperty {
    greaterThan: lone HEAT
}

sig TEMPERATURE extends ThermalProperty {}

sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

sig Substance extends ThermalThing {}

sig Cup extends ThermalThing {}

sig Coffee extends Substance {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}

one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE extends HEAT {}

one sig HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact {
    QuallitativeState = INCREASING + DECREASING + NOCHANGE
    no (INCREASING & DECREASING)
    no (INCREASING & NOCHANGE)
    no (DECREASING & NOCHANGE)

    Thing = ThermalThing
    ThermalThing = Substance + Cup
    Substance = Coffee
    no (Substance & Cup)

    ThermalProperty = Property
    no (HEAT & TEMPERATURE)

    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
    no (TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP)

    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
    no (HEAT_OF_COFFEE & HEAT_OF_CUP)

    Process = HeatFlow
}

fact {
    all t: Thing | t not in t.touches
    touches = ~touches

    all h: HEAT | h not in h.greaterThan
    greaterThan != ~greaterThan
}

fact {
    hasProperty =
        (Coffee -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE)) +
        (Cup -> (TEMPERATURE_OF_CUP + HEAT_OF_CUP))

    influences =
        (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
        (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)
}

fact {
    all t: ThermalThing |
        (no (t.touches & (Cup + Coffee))) implies
        (no HEAT.greaterThan and no HeatFlow)

    all t: ThermalThing |
        ((t.touches in (Cup + Coffee)) iff
            (
                (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) or
                (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) or
                (
                    (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan) and
                    (HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan)
                )
            ))

    all t: ThermalThing |
        (
            (t.touches in (Cup + Coffee)) and
            (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan) and
            (HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan)
        ) implies
        (
            (HEAT_OF_CUP not in HeatFlow.increases) and
            (HEAT_OF_COFFEE not in HeatFlow.increases) and
            (HEAT_OF_COFFEE not in HeatFlow.decreases) and
            (HEAT_OF_CUP not in HeatFlow.decreases)
        )

    all t: ThermalThing |
        (
            (t.touches in (Cup + Coffee)) and
            (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
        ) implies
        (
            (HEAT_OF_COFFEE.state = INCREASING) and
            (TEMPERATURE_OF_COFFEE.state = INCREASING) and
            (HEAT_OF_CUP.state = DECREASING) and
            (TEMPERATURE_OF_CUP.state = DECREASING) and
            (HeatFlow.increases = HEAT_OF_COFFEE) and
            (HeatFlow.decreases = HEAT_OF_CUP)
        )

    all t: ThermalThing |
        (
            (t.touches in (Cup + Coffee)) and
            (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
        ) implies
        (
            (HEAT_OF_COFFEE.state = DECREASING) and
            (TEMPERATURE_OF_COFFEE.state = DECREASING) and
            (HEAT_OF_CUP.state = INCREASING) and
            (TEMPERATURE_OF_CUP.state = INCREASING) and
            (HeatFlow.increases = HEAT_OF_CUP) and
            (HeatFlow.decreases = HEAT_OF_COFFEE)
        )
}