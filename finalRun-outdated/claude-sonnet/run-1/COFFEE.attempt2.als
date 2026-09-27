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

sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

sig ThermalThing in Thing {}
fact ThermalThingIsThing {
    ThermalThing = Thing
}

one sig Substance in ThermalThing {}
one sig Cup in ThermalThing {}

fact ThermalThingExact {
    ThermalThing = Substance + Cup
}

fact SubstanceCupDisjoint {
    no (Substance & Cup)
}

one sig Coffee in Substance {}

fact CoffeeIsOnlySubstance {
    Substance = Coffee
}

sig ThermalProperty in Property {}
fact ThermalPropertyIsProperty {
    ThermalProperty = Property
}

sig HEAT in ThermalProperty {
    greaterThan: lone HEAT
}

sig TEMPERATURE in ThermalProperty {}

fact HeatTemperatureDisjoint {
    no (HEAT & TEMPERATURE)
}

one sig TEMPERATURE_OF_COFFEE in TEMPERATURE {}
one sig TEMPERATURE_OF_CUP in TEMPERATURE {}

fact TemperatureExact {
    TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
}

fact TemperatureDisjoint {
    no (TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP)
}

one sig HEAT_OF_COFFEE in HEAT {}
one sig HEAT_OF_CUP in HEAT {}

fact HeatExact {
    HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
}

fact HeatDisjoint {
    no (HEAT_OF_COFFEE & HEAT_OF_CUP)
}

one sig HeatFlow in Process {}

fact HeatFlowExact {
    Process = HeatFlow
}

fact TouchesIrreflexive {
    all t: Thing | t not in t.touches
}

fact TouchesSymmetric {
    touches = ~touches
}

fact HasPropertyFacts {
    Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
    Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
    all t: Thing | (t != Coffee and t != Cup) implies no t.hasProperty
}

fact InfluencesFacts {
    HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
    HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
    all p: Property | (p != HEAT_OF_COFFEE and p != HEAT_OF_CUP) implies no p.influences
}

fact GreaterThanIrreflexive {
    all h: HEAT | h not in h.greaterThan
}

fact GreaterThanNotSymmetric {
    greaterThan != ~greaterThan
}

fact NoTouchNoGreaterThanNoHeatFlow {
    all tt: ThermalThing |
        (no (tt.touches & Cup) and no (tt.touches & Coffee))
        implies (no greaterThan and no HeatFlow)
}

fact TouchesCupOrCoffeeIff {
    all tt: ThermalThing |
        (tt.touches in (Cup + Coffee)) <=> (
            (HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan)
            or (HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan)
            or ((HEAT_OF_CUP -> HEAT_OF_COFFEE not in greaterThan) and (HEAT_OF_COFFEE -> HEAT_OF_CUP not in greaterThan))
        )
}

fact NoChangeCase {
    all tt: ThermalThing |
        ((tt.touches in (Cup + Coffee))
         and (HEAT_OF_CUP -> HEAT_OF_COFFEE not in greaterThan)
         and (HEAT_OF_COFFEE -> HEAT_OF_CUP not in greaterThan))
        implies (
            HeatFlow.increases != HEAT_OF_CUP
            and HeatFlow.increases != HEAT_OF_COFFEE
            and HeatFlow.decreases != HEAT_OF_COFFEE
            and HeatFlow.decreases != HEAT_OF_CUP
        )
}

fact CupGreaterCase {
    all tt: ThermalThing |
        ((tt.touches in (Cup + Coffee)) and (HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan))
        implies (
            HEAT_OF_COFFEE.state = INCREASING
            and TEMPERATURE_OF_COFFEE.state = INCREASING
            and HEAT_OF_CUP.state = DECREASING
            and TEMPERATURE_OF_CUP.state = DECREASING
            and increases.HEAT_OF_COFFEE in HeatFlow
            and decreases.HEAT_OF_CUP in HeatFlow
        )
}

fact CoffeeGreaterCase {
    all tt: ThermalThing |
        ((tt.touches in (Cup + Coffee)) and (HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan))
        implies (
            HEAT_OF_COFFEE.state = DECREASING
            and TEMPERATURE_OF_COFFEE.state = DECREASING
            and HEAT_OF_CUP.state = INCREASING
            and TEMPERATURE_OF_CUP.state = INCREASING
            and increases.HEAT_OF_CUP in HeatFlow
            and decreases.HEAT_OF_COFFEE in HeatFlow
        )
}