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
sig ThermalProperty extends Property {}

sig HEAT extends ThermalProperty {
    greaterThan: lone HEAT
}

sig TEMPERATURE extends ThermalProperty {}

one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}
one sig Coffee extends Substance {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact {
    Thing = ThermalThing
    ThermalThing = Substance + Cup
    Property = ThermalProperty
    QuallitativeState = INCREASING + DECREASING + NOCHANGE
    Process = HeatFlow

    Substance != Cup

    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP

    Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
    Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
    all t: Thing - Coffee - Cup | no t.hasProperty

    HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
    HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
    all p: Property - HEAT_OF_COFFEE - HEAT_OF_CUP | no p.influences
}

fact {
    no iden & HEAT.greaterThan
    HEAT.greaterThan != ~HEAT.greaterThan

    no iden & Thing.touches
    Thing.touches = ~Thing.touches
}

fact {
    all t: ThermalThing |
        (some (t.touches & (Cup + Coffee))) iff
        (
            (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
            or
            (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
            or
            (
                not (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
                and
                not (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
            )
        )
}

fact {
    all t: ThermalThing |
        no (t.touches & (Cup + Coffee)) implies
        (
            no HEAT.greaterThan
            and
            no HeatFlow
        )
}

fact {
    all t: ThermalThing |
        (
            some (t.touches & (Cup + Coffee))
            and
            not (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
            and
            not (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
        ) implies
        (
            HEAT_OF_CUP not in HeatFlow.increases
            and
            HEAT_OF_COFFEE not in HeatFlow.increases
            and
            HEAT_OF_COFFEE not in HeatFlow.decreases
            and
            HEAT_OF_CUP not in HeatFlow.decreases
        )
}

fact {
    all t: ThermalThing |
        (
            some (t.touches & (Cup + Coffee))
            and
            HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
        ) implies
        (
            HEAT_OF_COFFEE.state = INCREASING
            and
            TEMPERATURE_OF_COFFEE.state = INCREASING
            and
            HEAT_OF_CUP.state = DECREASING
            and
            TEMPERATURE_OF_CUP.state = DECREASING
            and
            (all p: Process | p.increases = HEAT_OF_COFFEE iff p = HeatFlow)
            and
            (all p: Process | p.decreases = HEAT_OF_CUP iff p = HeatFlow)
        )
}

fact {
    all t: ThermalThing |
        (
            some (t.touches & (Cup + Coffee))
            and
            HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
        ) implies
        (
            HEAT_OF_COFFEE.state = DECREASING
            and
            TEMPERATURE_OF_COFFEE.state = DECREASING
            and
            HEAT_OF_CUP.state = INCREASING
            and
            TEMPERATURE_OF_CUP.state = INCREASING
            and
            (all p: Process | p.increases = HEAT_OF_CUP iff p = HeatFlow)
            and
            (all p: Process | p.decreases = HEAT_OF_COFFEE iff p = HeatFlow)
        )
}