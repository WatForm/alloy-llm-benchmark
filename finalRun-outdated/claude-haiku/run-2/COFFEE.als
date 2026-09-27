abstract sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

abstract sig Property {
  influences: set Property,
  state: one QuallitativeState
}

enum QuallitativeState { INCREASING, DECREASING, NOCHANGE }

abstract sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

sig ThermalThing extends Thing {}

sig Substance extends ThermalThing {}
sig Cup extends ThermalThing {}
sig Coffee extends Substance {}

sig HEAT extends Property {
  greaterThan: set HEAT
}

sig TEMPERATURE extends Property {}

sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

sig HEAT_OF_COFFEE extends HEAT {}
sig HEAT_OF_CUP extends HEAT {}

sig HeatFlow extends Process {}

fact {
  // Exactly one Substance and one Cup, distinct
  #Substance = 1
  #Cup = 1
  Substance != Cup
  
  // Exactly one Coffee, which is the only Substance
  #Coffee = 1
  Coffee in Substance
  all s: Substance | s = Coffee
  
  // All ThermalThings are Cup or Coffee
  all t: ThermalThing | t = Cup or t = Coffee
  #ThermalThing = 2
  
  // Property set divided into HEAT and TEMPERATURE (disjoint)
  no (HEAT & TEMPERATURE)
  HEAT + TEMPERATURE = Property
  
  // Exactly two TEMPERATUREs
  #TEMPERATURE = 2
  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
  
  // Exactly two HEATs
  #HEAT = 2
  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
  
  // Exactly one HeatFlow, no other Processes
  #HeatFlow = 1
  HeatFlow = Process
  
  // Coffee has TEMPERATURE_OF_COFFEE and HEAT_OF_COFFEE
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  
  // Cup has the same properties
  Cup.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  
  // Nothing else has properties
  all t: Thing | t != Coffee and t != Cup implies t.hasProperty = none
  
  // HEAT_OF_COFFEE influences TEMPERATURE_OF_COFFEE
  HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
  
  // HEAT_OF_CUP influences TEMPERATURE_OF_CUP
  HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
  
  // No other influences
  TEMPERATURE_OF_COFFEE.influences = none
  TEMPERATURE_OF_CUP.influences = none
  
  // touches is irreflexive
  all t: Thing | t not in t.touches
  
  // touches is symmetric
  all t1, t2: Thing | t2 in t1.touches iff t1 in t2.touches
  
  // greaterThan is irreflexive
  all h: HEAT | h not in h.greaterThan
  
  // greaterThan has at most one target per source
  all h: HEAT | #(h.greaterThan) <= 1
  
  // greaterThan is not symmetric
  greaterThan != ~greaterThan
  
  // Complex constraints
  let hf = (HeatFlow <: Process) |
    let noGreater = (no HEAT_OF_COFFEE.greaterThan & HEAT_OF_CUP and no HEAT_OF_CUP.greaterThan & HEAT_OF_COFFEE) |
    (
      (noGreater) implies (
        hf.increases not in (HEAT_OF_CUP + HEAT_OF_COFFEE) and
        hf.decreases not in (HEAT_OF_CUP + HEAT_OF_COFFEE)
      )
    ) and
    (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) implies (
      HEAT_OF_COFFEE.state = INCREASING and
      TEMPERATURE_OF_COFFEE.state = INCREASING and
      HEAT_OF_CUP.state = DECREASING and
      TEMPERATURE_OF_CUP.state = DECREASING and
      hf.increases = HEAT_OF_COFFEE and
      hf.decreases = HEAT_OF_CUP and
      (all p: Process | p != hf implies (HEAT_OF_COFFEE not in p.increases and HEAT_OF_CUP not in p.decreases))
    ) and
    (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) implies (
      HEAT_OF_COFFEE.state = DECREASING and
      TEMPERATURE_OF_COFFEE.state = DECREASING and
      HEAT_OF_CUP.state = INCREASING and
      TEMPERATURE_OF_CUP.state = INCREASING and
      hf.increases = HEAT_OF_CUP and
      hf.decreases = HEAT_OF_COFFEE and
      (all p: Process | p != hf implies (HEAT_OF_CUP not in p.increases and HEAT_OF_COFFEE not in p.decreases))
    )
}