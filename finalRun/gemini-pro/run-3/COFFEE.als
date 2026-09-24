sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

sig Property {
    influences: set Property,
    state: one QuallitativeState
}

abstract sig QuallitativeState {}
one sig INCREASING extends QuallitativeState {}
one sig DECREASING extends QuallitativeState {}
one sig NOCHANGE extends QuallitativeState {}
fact { QuallitativeState = INCREASING + DECREASING + NOCHANGE }

sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

sig ThermalThing extends Thing {}
fact { Thing in ThermalThing }

sig Substance extends ThermalThing {}
one sig Coffee extends Substance {}
fact { Substance = Coffee }

one sig Cup extends ThermalThing {}
fact { ThermalThing = Substance + Cup }

sig ThermalProperty in Property {}
fact { ThermalProperty = Property }

sig HEAT in ThermalProperty {
    greaterThan: lone HEAT
}

sig TEMPERATURE in ThermalProperty {}
fact { no HEAT & TEMPERATURE }

one sig TEMPERATURE_OF_COFFEE in TEMPERATURE {}
one sig TEMPERATURE_OF_CUP in TEMPERATURE {}
fact { TEMPERATURE_OF_COFFEE != TEMPERATURE_OF_CUP }
fact { TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP }

one sig HEAT_OF_COFFEE in HEAT {}
one sig HEAT_OF_CUP in HEAT {}
fact { HEAT_OF_COFFEE != HEAT_OF_CUP }
fact { HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP }

one sig HeatFlow in Process {}
fact { Process = HeatFlow }

fact { no h: HEAT | h in h.greaterThan }

fact { greaterThan != ~greaterThan }

fact { no t: Thing | t in t.touches }

fact { touches = ~touches }

fact {
    hasProperty = Coffee -> TEMPERATURE_OF_COFFEE + Coffee -> HEAT_OF_COFFEE + Cup -> TEMPERATURE_OF_CUP + Cup -> HEAT_OF_CUP
}

fact {
    influences = HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE + HEAT_OF_CUP -> TEMPERATURE_OF_CUP
}

fact {
    all t: ThermalThing | 
        (not (Cup in t.touches or Coffee in t.touches)) => 
        (no greaterThan and no HeatFlow)
}

fact {
    all t: ThermalThing | 
        (Cup in t.touches or Coffee in t.touches) <=> 
        (
            HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan or 
            HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan or 
            (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan)
        )
}

fact {
    all t: ThermalThing | 
        ( (Cup in t.touches or Coffee in t.touches) and (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan) ) => 
        (
            HEAT_OF_CUP not in HeatFlow.increases and
            HEAT_OF_COFFEE not in HeatFlow.increases and
            HEAT_OF_COFFEE not in HeatFlow.decreases and
            HEAT_OF_CUP not in HeatFlow.decreases
        )
}

fact {
    all t: ThermalThing | 
        ( (Cup in t.touches or Coffee in t.touches) and (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) ) => 
        (
            HEAT_OF_COFFEE.state = INCREASING and
            TEMPERATURE_OF_COFFEE.state = INCREASING and
            HEAT_OF_CUP.state = DECREASING and
            TEMPERATURE_OF_CUP.state = DECREASING and
            increases.HEAT_OF_COFFEE = HeatFlow and
            decreases.HEAT_OF_CUP = HeatFlow
        )
}

fact {
    all t: ThermalThing | 
        ( (Cup in t.touches or Coffee in t.touches) and (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) ) => 
        (
            HEAT_OF_COFFEE.state = DECREASING and
            TEMPERATURE_OF_COFFEE.state = DECREASING and
            HEAT_OF_CUP.state = INCREASING and
            TEMPERATURE_OF_CUP.state = INCREASING and
            increases.HEAT_OF_CUP = HeatFlow and
            decreases.HEAT_OF_COFFEE = HeatFlow
        )
}