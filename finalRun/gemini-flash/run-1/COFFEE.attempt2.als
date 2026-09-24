thought
enum QuallitativeState {
    INCREASING,
    DECREASING,
    NOCHANGE
}

abstract sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

abstract sig Property {
    influences: set Property,
    state: one QuallitativeState
}

abstract sig Process {
    increases: one HEAT,
    decreases: one HEAT
}

abstract sig ThermalThing extends Thing {}

abstract sig Substance extends ThermalThing {}

one sig Coffee extends Substance {}

one sig Cup extends ThermalThing {}

abstract sig ThermalProperty extends Property {}

abstract sig HEAT extends ThermalProperty {
    greaterThan: lone HEAT
}

abstract sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact {
    // All Things are ThermalThings
    Thing = ThermalThing

    // ThermalProperty is equal to Property
    ThermalProperty = Property

    // Relations constraints
    no iden & greaterThan
    greaterThan != ~greaterThan

    no iden & touches
    touches = ~touches

    // Properties of Coffee and Cup
    Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
    Cup.hasProperty = Coffee.hasProperty
    no (Thing - Coffee - Cup).hasProperty

    // Influences
    influences = HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE + HEAT_OF_CUP -> TEMPERATURE_OF_CUP

    // NAD: this seems to be impossible b/c there must be a "HeatFlow" element 
    all t: ThermalThing |
        (t.touches != Cup and t.touches != Coffee) implies (no greaterThan and no HeatFlow)

    all t: ThermalThing |
        (t.touches = Cup or t.touches = Coffee) iff (
            HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan or
            HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan or
            (HEAT_OF_CUP -> HEAT_OF_COFFEE not in greaterThan and HEAT_OF_COFFEE -> HEAT_OF_CUP not in greaterThan)
        )

    all t: ThermalThing |
        ((t.touches = Cup or t.touches = Coffee) and
         HEAT_OF_CUP -> HEAT_OF_COFFEE not in greaterThan and
         HEAT_OF_COFFEE -> HEAT_OF_CUP not in greaterThan) implies {
            HeatFlow.increases != HEAT_OF_CUP
            HeatFlow.increases != HEAT_OF_COFFEE
            HeatFlow.decreases != HEAT_OF_COFFEE
            HeatFlow.decreases != HEAT_OF_CUP
        }

    all t: ThermalThing |
        ((t.