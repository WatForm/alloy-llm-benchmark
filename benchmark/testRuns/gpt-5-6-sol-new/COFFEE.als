abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

abstract sig Property {
    influences: set Property,
    state: one QuallitativeState
}

sig ThermalProperty extends Property {}

abstract sig HEAT extends ThermalProperty {
    greaterThan: lone HEAT
}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

abstract sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

abstract sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

abstract sig ThermalThing extends Thing {}

one sig Substance, Cup extends ThermalThing {}

one sig Coffee extends Substance {}

abstract sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

one sig HeatFlow extends Process {}

fact {
    no h: HEAT | h in h.greaterThan
    greaterThan != ~greaterThan
}

fact {
    no t: Thing | t in t.touches
    touches = ~touches
}

fact {
    hasProperty =
        (Coffee -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE)) +
        (Cup -> (TEMPERATURE_OF_CUP + HEAT_OF_CUP))
}

fact {
    influences =
        (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
        (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)
}

fact {
    all t: ThermalThing |
        (Cup not in t.touches and Coffee not in t.touches)
        implies
        (no greaterThan and no HeatFlow)
}

fact {
    all t: ThermalThing |
        (Cup in t.touches or Coffee in t.touches)
        iff
        (
            HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
            or
            HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
            or
            (
                HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
                and
                HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
            )
        )
}

fact {
    all t: ThermalThing |
        (
            (Cup in t.touches or Coffee in t.touches)
            and
            HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
            and
            HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
        )
        implies
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
            (Cup in t.touches or Coffee in t.touches)
            and
            HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
        )
        implies
        (
            HEAT_OF_COFFEE.state = INCREASING
            and
            TEMPERATURE_OF_COFFEE.state = INCREASING
            and
            HEAT_OF_CUP.state = DECREASING
            and
            TEMPERATURE_OF_CUP.state = DECREASING
            and
            increases.HEAT_OF_COFFEE = HeatFlow
            and
            decreases.HEAT_OF_CUP = HeatFlow
        )
}

fact {
    all t: ThermalThing |
        (
            (Cup in t.touches or Coffee in t.touches)
            and
            HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
        )
        implies
        (
            HEAT_OF_COFFEE.state = DECREASING
            and
            TEMPERATURE_OF_COFFEE.state = DECREASING
            and
            HEAT_OF_CUP.state = INCREASING
            and
            TEMPERATURE_OF_CUP.state = INCREASING
            and
            increases.HEAT_OF_CUP = HeatFlow
            and
            decreases.HEAT_OF_COFFEE = HeatFlow
        )
}