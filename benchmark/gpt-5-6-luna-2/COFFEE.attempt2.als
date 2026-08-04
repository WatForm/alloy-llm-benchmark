sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

sig Property {
    influences: set Property,
    state: one QuallitativeState
}

enum QuallitativeState {
    INCREASING,
    DECREASING,
    NOCHANGE
}

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

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE extends HEAT {}
one sig HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact {
    Thing = ThermalThing
    ThermalThing = Substance + Cup
    ThermalProperty = Property
    Process = HeatFlow

    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP

    hasProperty =
        (Coffee -> TEMPERATURE_OF_COFFEE) +
        (Coffee -> HEAT_OF_COFFEE) +
        (Cup -> TEMPERATURE_OF_CUP) +
        (Cup -> HEAT_OF_CUP)

    influences =
        (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
        (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)

    all t: Thing | t not in t.touches
    touches = ~touches

    all h: HEAT | h not in h.greaterThan
    some h, k: HEAT |
        k in h.greaterThan and h not in k.greaterThan
}

fact {
    all t: ThermalThing |
        (some t.touches & (Cup + Coffee)) iff
        (
            HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
            or HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
            or (
                HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
                and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
            )
        )
}

fact {
    all t: ThermalThing |
        no (t.touches & (Cup + Coffee)) implies {
            all h: HEAT | no h.greaterThan
            no HeatFlow
        }
}

fact {
    all t: ThermalThing |
        some t.touches & (Cup + Coffee)
        and HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
        and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
        implies {
            HEAT_OF_CUP not in HeatFlow.increases
            HEAT_OF_COFFEE not in HeatFlow.increases
            HEAT_OF_COFFEE not in HeatFlow.decreases
            HEAT_OF_CUP not in HeatFlow.decreases
        }
}

fact {
    all t: ThermalThing |
        some t.touches & (Cup + Coffee)
        and HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
        implies {
            HEAT_OF_COFFEE.state = INCREASING
            TEMPERATURE_OF_COFFEE.state = INCREASING
            HEAT_OF_CUP.state = DECREASING
            TEMPERATURE_OF_CUP.state = DECREASING

            HEAT_OF_COFFEE in HeatFlow.increases
            HEAT_OF_CUP in HeatFlow.decreases

            all p: Process |
                HEAT_OF_COFFEE in p.increases implies p = HeatFlow
            all p: Process |
                HEAT_OF_CUP in p.decreases implies p = HeatFlow
        }
}

fact {
    all t: ThermalThing |
        some t.touches & (Cup + Coffee)
        and HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
        implies {
            HEAT_OF_COFFEE.state = DECREASING
            TEMPERATURE_OF_COFFEE.state = DECREASING
            HEAT_OF_CUP.state = INCREASING
            TEMPERATURE_OF_CUP.state = INCREASING

            HEAT_OF_CUP in HeatFlow.increases
            HEAT_OF_COFFEE in HeatFlow.decreases

            all p: Process |
                HEAT_OF_CUP in p.increases implies p = HeatFlow
            all p: Process |
                HEAT_OF_COFFEE in p.decreases implies p = HeatFlow
        }
}