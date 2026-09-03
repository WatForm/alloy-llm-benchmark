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
fact ThermalThingDef { Thing = ThermalThing }

one sig Substance in ThermalThing {}
one sig Cup in ThermalThing {}
fact SubstanceCupDisjointTotal {
  Substance != Cup
  ThermalThing = Substance + Cup
}

one sig Coffee in Substance {}
fact CoffeeDef { Coffee = Substance }

sig ThermalProperty in Property {}
fact ThermalPropertyDef { ThermalProperty = Property }

sig HEAT in ThermalProperty {
  greaterThan: lone HEAT
}
sig TEMPERATURE in ThermalProperty {}
fact HeatTempDisjoint { no (HEAT & TEMPERATURE) }

one sig TEMPERATURE_OF_COFFEE in TEMPERATURE {}
one sig TEMPERATURE_OF_CUP in TEMPERATURE {}
fact TemperatureDef {
  TEMPERATURE_OF_COFFEE != TEMPERATURE_OF_CUP
  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
}

one sig HEAT_OF_COFFEE in HEAT {}
one sig HEAT_OF_CUP in HEAT {}
fact HeatDef {
  HEAT_OF_COFFEE != HEAT_OF_CUP
  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
}

one sig HeatFlow in Process {}
fact ProcessDef { Process = HeatFlow }

fact greaterThanIrreflexive { all h: HEAT | h !in h.greaterThan }
fact greaterThanAsymmetric { greaterThan != ~greaterThan }

fact touchesIrreflexive { all t: Thing | t !in t.touches }
fact touchesSymmetric { touches = ~touches }

fact hasPropertyFact {
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
  all t: Thing | t !in (Coffee + Cup) implies no t.hasProperty
}

fact influencesFact {
  influences = HEAT_OF_COFFEE->TEMPERATURE_OF_COFFEE + HEAT_OF_CUP->TEMPERATURE_OF_CUP
}

fact noTouchCupOrCoffee {
  all t: ThermalThing |
    (Cup !in t.touches and Coffee !in t.touches) implies (no greaterThan and no HeatFlow)
}

fact touchesIff {
  all t: ThermalThing |
    (Cup in t.touches or Coffee in t.touches)
    iff
    (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
     or HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
     or (HEAT_OF_CUP !in HEAT_OF_COFFEE.greaterThan and HEAT_OF_COFFEE !in HEAT_OF_CUP.greaterThan))
}

fact noChangeCase {
  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches)
     and
     (HEAT_OF_CUP !in HEAT_OF_COFFEE.greaterThan and HEAT_OF_COFFEE !in HEAT_OF_CUP.greaterThan))
    implies
    (
      HeatFlow.increases != HEAT_OF_CUP
      and HeatFlow.increases != HEAT_OF_COFFEE
      and HeatFlow.decreases != HEAT_OF_COFFEE
      and HeatFlow.decreases != HEAT_OF_CUP
    )
}

fact cupGreaterCase {
  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches)
     and
     (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan))
    implies
    (
      HEAT_OF_COFFEE.state = INCREASING
      and TEMPERATURE_OF_COFFEE.state = INCREASING
      and HEAT_OF_CUP.state = DECREASING
      and TEMPERATURE_OF_CUP.state = DECREASING
      and (all p: Process | p.increases = HEAT_OF_COFFEE implies p = HeatFlow)
      and (all p: Process | p.decreases = HEAT_OF_CUP implies p = HeatFlow)
    )
}

fact coffeeGreaterCase {
  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches)
     and
     (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan))
    implies
    (
      HEAT_OF_COFFEE.state = DECREASING
      and TEMPERATURE_OF_COFFEE.state = DECREASING
      and HEAT_OF_CUP.state = INCREASING
      and TEMPERATURE_OF_CUP.state = INCREASING
      and (all p: Process | p.increases = HEAT_OF_CUP implies p = HeatFlow)
      and (all p: Process | p.decreases = HEAT_OF_COFFEE implies p = HeatFlow)
    )
}