abstract sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

abstract sig ThermalThing extends Thing {}

one sig Coffee extends ThermalThing {}
one sig Cup extends ThermalThing {}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

abstract sig ThermalProperty extends Property {}

sig HEAT extends ThermalProperty {
  greaterThan: lone HEAT
}

sig TEMPERATURE extends ThermalProperty {}

abstract sig QuallitativeState {}
one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE extends HEAT {}
one sig HEAT_OF_CUP extends HEAT {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

one sig HeatFlow extends Process {}

fact AllThingsAreThermalThings {
  Thing = ThermalThing
}

fact OnlyTwoThermalThings {
  ThermalThing = Coffee + Cup
}

fact ThermalPropertyEqualsProperty {
  ThermalProperty = Property
}

fact HALTAndTEMPERATUREDisjoint {
  no HEAT & TEMPERATURE
}

fact OnlyHALTAndTEMPERATUREInProperty {
  Property = HEAT + TEMPERATURE
}

fact OnlyTwoTemperatures {
  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
}

fact OnlyTwoHeats {
  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
}

fact OnlyHeatFlowIsProcess {
  Process = HeatFlow
}

fact TouchesNotReflexive {
  no t: Thing | t.touches = t
}

fact TouchesSymmetric {
  touches = ~touches
}

fact CoffeeAndCupTouchEachOther {
  Coffee.touches = Cup and Cup.touches = Coffee
}

fact CoffeeHasProperties {
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
}

fact CupHasProperties {
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
}

fact OnlyHasPropertiesConstraint {
  (Coffee + Cup).hasProperty = Property
}

fact InfluencesConstraints {
  HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
  HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
  TEMPERATURE_OF_COFFEE.influences = none
  TEMPERATURE_OF_CUP.influences = none
}

fact GreaterThanNotReflexive {
  no h: HEAT | h.greaterThan = h
}

fact GreaterThanNotSymmetric {
  no h1, h2: HEAT | h1.greaterThan = h2 and h2.greaterThan = h1
}

fact OneOfThreeConditionsHolds {
  (HEAT_OF_COFFEE.greaterThan = HEAT_OF_CUP) or
  (HEAT_OF_CUP.greaterThan = HEAT_OF_COFFEE) or
  (HEAT_OF_COFFEE.greaterThan != HEAT_OF_CUP and HEAT_OF_CUP.greaterThan != HEAT_OF_COFFEE)
}

fact ConditionThreeConstraints {
  (HEAT_OF_COFFEE.greaterThan != HEAT_OF_CUP and HEAT_OF_CUP.greaterThan != HEAT_OF_COFFEE) => (
    HeatFlow.increases != HEAT_OF_CUP and
    HeatFlow.increases != HEAT_OF_COFFEE and
    HeatFlow.decreases != HEAT_OF_COFFEE and
    HeatFlow.decreases != HEAT_OF_CUP
  )
}

fact ConditionTwoConstraints {
  (HEAT_OF_CUP.greaterThan = HEAT_OF_COFFEE) => (
    HEAT_OF_COFFEE.state = INCREASING and
    TEMPERATURE_OF_COFFEE.state = INCREASING and
    HEAT_OF_CUP.state = DECREASING and
    TEMPERATURE_OF_CUP.state = DECREASING and
    HeatFlow.increases = HEAT_OF_COFFEE and
    HeatFlow.decreases = HEAT_OF_CUP
  )
}

fact ConditionOneConstraints {
  (HEAT_OF_COFFEE.greaterThan = HEAT_OF_CUP) => (
    HEAT_OF_COFFEE.state = DECREASING and
    TEMPERATURE_OF_COFFEE.state = DECREASING and
    HEAT_OF_CUP.state = INCREASING and
    TEMPERATURE_OF_CUP.state = INCREASING and
    HeatFlow.increases = HEAT_OF_CUP and
    HeatFlow.decreases = HEAT_OF_COFFEE
  )
}