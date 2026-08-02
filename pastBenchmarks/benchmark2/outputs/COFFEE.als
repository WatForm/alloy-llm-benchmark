abstract sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

abstract sig Property {
  influences: set Property,
  state: one QualitativeState
}

abstract sig QualitativeState {}
one sig INCREASING, DECREASING, NOCHANGE extends QualitativeState {}

abstract sig ThermalThing extends Thing {}
sig Substance extends ThermalThing {}
sig Cup extends ThermalThing {}
sig Coffee extends ThermalThing {}

abstract sig ThermalProperty extends Property {}
sig TEMPERATURE extends ThermalProperty {}
sig HEAT extends ThermalProperty {
  greaterThan: lone HEAT
}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

one sig HeatFlow extends Process {}

fact basicStructure {
  no iden & greaterThan
  greaterThan != ~greaterThan

  no iden & touches
  touches = ~touches

  hasProperty = Coffee->(TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE)
              + Cup->(TEMPERATURE_OF_CUP + HEAT_OF_CUP)

  influences = HEAT_OF_COFFEE->TEMPERATURE_OF_COFFEE
             + HEAT_OF_CUP->TEMPERATURE_OF_CUP
}

pred thermalThingsNotTouchingCupOrCoffee {
  all t: ThermalThing | t not in Cup.touches + Coffee.touches
}

pred thermalThingsTouchingCupOrCoffee {
  all t: ThermalThing | t in Cup.touches + Coffee.touches
}

pred touchingWithCupHeatGreater {
  all t: ThermalThing |
    t in Cup.touches + Coffee.touches implies HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
}

pred touchingWithCoffeeHeatGreater {
  all t: ThermalThing |
    t in Cup.touches + Coffee.touches implies HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
}

fact heatFlowFromCupToCoffee {
  HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan implies
    HeatFlow.increases = HEAT_OF_COFFEE and
    HeatFlow.decreases = HEAT_OF_CUP and
    HEAT_OF_COFFEE.state = INCREASING and
    HEAT_OF_CUP.state = DECREASING and
    TEMPERATURE_OF_COFFEE.state = INCREASING and
    TEMPERATURE_OF_CUP.state = DECREASING
}

fact heatFlowFromCoffeeToCup {
  HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan implies
    HeatFlow.increases = HEAT_OF_CUP and
    HeatFlow.decreases = HEAT_OF_COFFEE and
    HEAT_OF_CUP.state = INCREASING and
    HEAT_OF_COFFEE.state = DECREASING and
    TEMPERATURE_OF_CUP.state = INCREASING and
    TEMPERATURE_OF_COFFEE.state = DECREASING
}

fact noHeatFlowNoChange {
  no greaterThan implies
    HEAT_OF_COFFEE.state = NOCHANGE and
    HEAT_OF_CUP.state = NOCHANGE and
    TEMPERATURE_OF_COFFEE.state = NOCHANGE and
    TEMPERATURE_OF_CUP.state = NOCHANGE
}

run thermalThingsNotTouchingCupOrCoffee for 8
run thermalThingsTouchingCupOrCoffee for 8
run touchingWithCupHeatGreater for 8
run touchingWithCoffeeHeatGreater for 8