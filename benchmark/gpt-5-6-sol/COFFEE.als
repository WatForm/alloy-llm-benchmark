abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Property {
    influences: set Property,
    state: one QuallitativeState
}

sig ThermalProperty in Property {}

sig HEAT in ThermalProperty {
    greaterThan: lone HEAT
}

sig TEMPERATURE in ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP in TEMPERATURE {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP in HEAT {}

abstract sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

one sig HeatFlow extends Process {}

abstract sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

abstract sig ThermalThing extends Thing {}

one sig Substance, Cup extends ThermalThing {}

one sig Coffee extends Substance {}

fact {
    ThermalProperty = Property

    no HEAT & TEMPERATURE

    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
    no TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP

    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
    no HEAT_OF_COFFEE & HEAT_OF_CUP
}

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
        Coffee -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE) +
        Cup -> (TEMPERATURE_OF_CUP + HEAT_OF_CUP)
}

fact {
    influences =
        HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE +
        HEAT_OF_CUP -> TEMPERATURE_OF_CUP
}

fact {
    all t: ThermalThing |
        no (t.touches & (Cup + Coffee)) implies
            (no greaterThan and no HeatFlow)
}

fact {
    all t: ThermalThing |
        some (t.touches & (Cup + Coffee)) iff
            (
                (HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan
                or
                (HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan
                or
                (
                    not ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan)
                    and
                    not ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan)
                )
            )
}

fact {
    all t: ThermalThing |
        (
            some (t.touches & (Cup + Coffee))
            and
            not ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan)
            and
            not ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan)
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
            (HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan
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
            increases.TEMPERATURE_OF_COFFEE = none
            and
            increases.HEAT_OF_COFFEE = HeatFlow
            and
            decreases.HEAT_OF_CUP = HeatFlow
        )
}

fact {
    all t: ThermalThing |
        (
            some (t.touches & (Cup + Coffee))
            and
            (HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan
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
            increases.HEAT_OF_CUP = HeatFlow
            and
            decreases.HEAT_OF_COFFEE = HeatFlow
        )
}