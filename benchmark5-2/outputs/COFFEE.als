abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Property {
    influences: set Property,
    state: one QuallitativeState
}

sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

abstract sig ThermalThing extends Thing {}

one sig Substance extends ThermalThing {}

one sig Cup extends ThermalThing {}

one sig Coffee extends Substance {}

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

fact {
    Thing = ThermalThing
    ThermalThing = Substance + Cup
    Substance = Coffee
    ThermalProperty = Property
    no HEAT & TEMPERATURE
    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
    no TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP
    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
    no HEAT_OF_COFFEE & HEAT_OF_CUP
    Process = HeatFlow
}

fact {
    all t: Thing | t not in t.touches
    touches = ~touches
}

fact {
    all h: HEAT | h not in h.greaterThan
    greaterThan != ~greaterThan
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
        no (t.touches & (Cup + Coffee)) => {
            no greaterThan
            no HeatFlow
        }
}

fact {
    all t: ThermalThing |
        some (t.touches & (Cup + Coffee)) iff (
            ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan) or
            ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan) or
            (
                ((HEAT_OF_CUP -> HEAT_OF_COFFEE) not in greaterThan) and
                ((HEAT_OF_COFFEE -> HEAT_OF_CUP) not in greaterThan)
            )
        )
}

fact {
    all t: ThermalThing |
        (
            some (t.touches & (Cup + Coffee)) and
            ((HEAT_OF_CUP -> HEAT_OF_COFFEE) not in greaterThan) and
            ((HEAT_OF_COFFEE -> HEAT_OF_CUP) not in greaterThan)
        ) => {
            HEAT_OF_CUP not in HeatFlow.increases
            HEAT_OF_COFFEE not in HeatFlow.increases
            HEAT_OF_COFFEE not in HeatFlow.decreases
            HEAT_OF_CUP not in HeatFlow.decreases
        }
}

fact {
    all t: ThermalThing |
        (
            some (t.touches & (Cup + Coffee)) and
            ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan)
        ) => {
            HEAT_OF_COFFEE.state = INCREASING
            TEMPERATURE_OF_COFFEE.state = INCREASING
            HEAT_OF_CUP.state = DECREASING
            TEMPERATURE_OF_CUP.state = DECREASING
            HeatFlow.increases = HEAT_OF_COFFEE
            HeatFlow.decreases = HEAT_OF_CUP
        }
}

fact {
    all t: ThermalThing |
        (
            some (t.touches & (Cup + Coffee)) and
            ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan)
        ) => {
            HEAT_OF_COFFEE.state = DECREASING
            TEMPERATURE_OF_COFFEE.state = DECREASING
            HEAT_OF_CUP.state = INCREASING
            TEMPERATURE_OF_CUP.state = INCREASING
            HeatFlow.increases = HEAT_OF_CUP
            HeatFlow.decreases = HEAT_OF_COFFEE
        }
}