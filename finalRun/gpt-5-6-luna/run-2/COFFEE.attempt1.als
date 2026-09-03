sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

sig Property {
    influences: set Property,
    state: one QuallitativeState
}

sig QuallitativeState {}
sig Process {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig ThermalThing extends Thing {}
one sig Substance, Cup extends ThermalThing {}
one sig Coffee extends Substance {}

sig ThermalProperty extends Property {}
sig HEAT extends ThermalProperty {
    greaterThan: lone HEAT
}
sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {
    increases: one HEAT,
    decreases: one HEAT
}

fact {
    QuallitativeState = INCREASING + DECREASING + NOCHANGE
    Thing = ThermalThing
    ThermalThing = Substance + Cup
    ThermalProperty = Property
    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
    Process = HeatFlow
}

fact {
    no (iden & touches)
    touches = ~touches
    no (iden & greaterThan)
    greaterThan != ~greaterThan
}

fact {
    Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
    Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
    all t: Thing | t in Coffee + Cup or no t.hasProperty

    HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
    HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
    all p: Property |
        p in HEAT_OF_COFFEE + HEAT_OF_CUP or no p.influences
}

fact {
    all t: ThermalThing |
        (no (t.touches & (Cup + Coffee))) implies
        (no greaterThan and no HeatFlow)

    all t: ThermalThing |
        ((t.touches in Cup + Coffee) iff
            (
                HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
                or HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
                or (
                    not (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
                    and not (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
                )
            ))

    all t: ThermalThing |
        (
            t.touches in Cup + Coffee
            and not (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
            and not (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
        ) implies
        (
            HEAT_OF_CUP not in HeatFlow.increases
            and HEAT_OF_COFFEE not in HeatFlow.increases
            and HEAT_OF_COFFEE not in HeatFlow.decreases
            and HEAT_OF_CUP not in HeatFlow.decreases
        )

    all t: ThermalThing |
        (
            t.touches in Cup + Coffee
            and HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
        ) implies
        (
            HEAT_OF_COFFEE.state = INCREASING
            and TEMPERATURE_OF_COFFEE.state = INCREASING
            and HEAT_OF_CUP.state = DECREASING
            and TEMPERATURE_OF_CUP.state = DECREASING
            and HeatFlow.increases = HEAT_OF_COFFEE
            and HeatFlow.decreases = HEAT_OF_CUP
        )

    all t: ThermalThing |
        (
            t.touches in Cup + Coffee
            and HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
        ) implies
        (
            HEAT_OF_COFFEE.state = DECREASING
            and TEMPERATURE_OF_COFFEE.state = DECREASING
            and HEAT_OF_CUP.state = INCREASING
            and TEMPERATURE_OF_CUP.state = INCREASING
            and HeatFlow.increases = HEAT_OF_CUP
            and HeatFlow.decreases = HEAT_OF_COFFEE
        )
}