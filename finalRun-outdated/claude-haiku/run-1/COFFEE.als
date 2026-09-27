abstract sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

abstract sig Property {
  influences: set Property,
  state: one QuallitativeState
}

enum QuallitativeState {
  INCREASING, DECREASING, NOCHANGE
}

abstract sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

sig ThermalThing extends Thing {}

sig Substance extends ThermalThing {}

sig Cup extends ThermalThing {}

sig Coffee extends Substance {}

abstract sig ThermalProperty extends Property {}

abstract sig HEAT extends ThermalProperty {
  greaterThan: set HEAT
}

abstract sig TEMPERATURE extends ThermalProperty {}

one sig HEAT_OF_COFFEE extends HEAT {}
one sig HEAT_OF_CUP extends HEAT {}

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

sig HeatFlow extends Process {}

fact {
  Thing = ThermalThing
}

fact {
  #Substance = 1
  #Cup = 1
  Substance != Cup
  Substance = Coffee
  #Coffee = 1
}

fact {
  ThermalProperty = Property
  HEAT & TEMPERATURE = none
  HEAT + TEMPERATURE = Property
}

fact {
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
  all t: Thing | t not in (Coffee + Cup) => no t.hasProperty
}

fact {
  HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
  HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
  all p: Property | p not in (HEAT_OF_COFFEE + HEAT_OF_CUP) => no p.influences
}

fact {
  #HeatFlow = 1
  Process = HeatFlow
}

fact {
  all h: HEAT | #(h.greaterThan) <= 1
}

fact {
  all h: HEAT | h not in h.greaterThan
}

fact {
  greaterThan != ~greaterThan
}

fact {
  all t: Thing | t not in t.touches
}

fact {
  touches = ~touches
}

fact {
  (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) => {
    HEAT_OF_COFFEE.state = INCREASING and
    TEMPERATURE_OF_COFFEE.state = INCREASING and
    HEAT_OF_CUP.state = DECREASING and
    TEMPERATURE_OF_CUP.state = DECREASING and
    HeatFlow.increases = HEAT_OF_COFFEE and
    HeatFlow.decreases = HEAT_OF_CUP
  }
}

fact {
  (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) => {
    HEAT_OF_COFFEE.state = DECREASING and
    TEMPERATURE_OF_COFFEE.state = DECREASING and
    HEAT_OF_CUP.state = INCREASING and
    TEMPERATURE_OF_CUP.state = INCREASING and
    HeatFlow.increases = HEAT_OF_CUP and
    HeatFlow.decreases = HEAT_OF_COFFEE
  }
}

fact {
  (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan) => {
    HEAT_OF_COFFEE not in HeatFlow.increases and
    HEAT_OF_CUP not in HeatFlow.increases and
    HEAT_OF_COFFEE not in HeatFlow.decreases and
    HEAT_OF_CUP not in HeatFlow.decreases
  }
}