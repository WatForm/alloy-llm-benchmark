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
sig HEAT, TEMPERATURE extends ThermalProperty {}

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

    Thing.hasProperty =
        (Coffee -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE)) +
        (Cup -> (TEMPERATURE_OF_CUP + HEAT_OF_CUP))

    Property.influences =
        (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
        (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)

    no Thing & touches[Thing]
    touches = ~touches

    all h: HEAT | lone h.greaterThan
    no iden & greaterThan
    greaterThan != ~greaterThan
}

fact {
    all t: ThermalThing |
        (t.touches in Cup + Coffee) iff
        (
            HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
            or HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
            or (
                HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
                and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
            )
        )
}

fact {
    all t: ThermalThing |
        t.touches not in Cup + Coffee implies {
            no greaterThan
            no HeatFlow
        }
}

fact {
    all t: ThermalThing |
        t.touches in Cup + Coffee
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
        t.touches in Cup + Coffee
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
        t.touches in Cup + Coffee
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