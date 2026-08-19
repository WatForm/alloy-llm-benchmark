sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

sig Property {
    influences: set Property,
    state: one QuallitativeState
}

abstract sig QuallitativeState {}
one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

abstract sig ThermalThing extends Thing {}
one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}
one sig Coffee extends Substance {}

abstract sig ThermalProperty extends Property {}
abstract sig HEAT extends ThermalProperty {
    greaterThan: lone HEAT
}
abstract sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact {
    Thing = ThermalThing
    ThermalThing = Substance + Cup
    Substance != Cup
    Process = HeatFlow
    Property = ThermalProperty

    HEAT & TEMPERATURE = none

    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
    TEMPERATURE_OF_COFFEE != TEMPERATURE_OF_CUP

    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
    HEAT_OF_COFFEE != HEAT_OF_CUP

    greaterThan != ~greaterThan
    all h: HEAT | h not in h.greaterThan

    Thing.touches = ~Thing.touches
    all t: Thing | t not in t.touches

    Thing.hasProperty =
        (Coffee -> TEMPERATURE_OF_COFFEE) +
        (Coffee -> HEAT_OF_COFFEE) +
        (Cup -> TEMPERATURE_OF_CUP) +
        (Cup -> HEAT_OF_CUP)

    Property.influences =
        (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
        (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)

    all t: ThermalThing |
        (Cup not in t.touches and Coffee not in t.touches) implies
            (no greaterThan and no HeatFlow)

    all t: ThermalThing |
        (Cup in t.touches or Coffee in t.touches) iff
            (
                HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
                or HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
                or (
                    HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
                    and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
                )
            )

    all t: ThermalThing |
        (
            (Cup in t.touches or Coffee in t.touches)
            and
            HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
            and
            HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
        ) implies
        (
            HEAT_OF_CUP not in HeatFlow.increases
            and HEAT_OF_COFFEE not in HeatFlow.increases
            and HEAT_OF_COFFEE not in HeatFlow.decreases
            and HEAT_OF_CUP not in HeatFlow.decreases
        )

    all t: ThermalThing |
        (
            (Cup in t.touches or Coffee in t.touches)
            and
            HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
        ) implies
        (
            HEAT_OF_COFFEE.state = INCREASING
            and TEMPERATURE_OF_COFFEE.state = INCREASING
            and HEAT_OF_CUP.state = DECREASING
            and TEMPERATURE_OF_CUP.state = DECREASING
            and HEAT_OF_COFFEE.~increases = HeatFlow
            and HEAT_OF_CUP.~decreases = HeatFlow
        )

    all t: ThermalThing |
        (
            (Cup in t.touches or Coffee in t.touches)
            and
            HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
        ) implies
        (
            HEAT_OF_COFFEE.state = DECREASING
            and TEMPERATURE_OF_COFFEE.state = DECREASING
            and HEAT_OF_CUP.state = INCREASING
            and TEMPERATURE_OF_CUP.state = INCREASING
            and HEAT_OF_CUP.~increases = HeatFlow
            and HEAT_OF_COFFEE.~decreases = HeatFlow
        )
}