abstract sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

abstract sig Property {
    influences: set Property,
    state: one QuallitativeState
}

abstract sig QuallitativeState {}
one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

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
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

abstract sig TEMPERATURE extends ThermalProperty {}
one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HeatFlow extends Process {}

fact {
    // All "Thing"s are "ThermalThing"s. There are no other "ThermalThing"s.
    Thing = ThermalThing
    ThermalThing = Substance + Cup
    Substance = Coffee

    // The set "ThermalProperty" is equal to the set "Property".
    ThermalProperty = Property

    // There are no "Process"es that aren't in "HeatFlow".
    Process = HeatFlow

    // The "greaterThan" relation never relates any "HEAT" to itself.
    no iden & greaterThan
    // The "greaterThan" relation is not equal to its converse.
    greaterThan != ~greaterThan

    // The "touches" relation never relates any "Thing" to itself.
    no iden & touches
    // The "touches" relation is symmetric.
    touches = ~touches

    // "Coffee" "hasProperty" "TEMPERATURE_OF_COFFEE" and also "HEAT_OF_COFFEE".
    // "Cup" has the same properties. Nothing else has properties.
    Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
    Cup.hasProperty = Coffee.hasProperty
    no (Thing - Coffee - Cup).hasProperty

    // "HEAT_OF_COFFEE" influences "TEMPERATURE_OF_COFFEE", and "HEAT_OF_CUP" influences "TEMPERATURE_OF_CUP".
    // There are no other influences.
    influences = HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE + HEAT_OF_CUP -> TEMPERATURE_OF_CUP

    // If a "ThermalThing" "touches" neither "Cup" nor "Coffee", then there is no "greaterThan" relationship at all and there is no "HeatFlow".
    all t: ThermalThing | (Cup !in t.touches and Coffee !in t.touches) => (no greaterThan and no HeatFlow)

    // A "ThermalThing" "touches" "Cup" or "Coffee" if and only if one of