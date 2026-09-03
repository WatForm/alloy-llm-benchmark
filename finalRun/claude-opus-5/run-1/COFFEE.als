abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

abstract sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

abstract sig ThermalThing extends Thing {}

fact { Thing = ThermalThing }

abstract sig Substance extends ThermalThing {}

one sig Cup extends ThermalThing {}

one sig Coffee extends Substance {}

sig ThermalProperty extends Property {}

fact { Property = ThermalProperty }

abstract sig HEAT extends ThermalProperty {
  greaterThan: lone HEAT
}

abstract sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact { Process = HeatFlow }

fact NoSelfGreaterThan {
  no h: HEAT | h in h.greaterThan
}

fact GreaterThanNotSymmetric {
  greaterThan != ~greaterThan
}

fact NoSelfTouch {
  no t: Thing | t in t.touches
}

fact TouchesSymmetric {
  touches = ~touches
}

fact Properties {
  hasProperty = Coffee->TEMPERATURE_OF_COFFEE + Coffee->HEAT_OF_COFFEE
              + Cup->TEMPERATURE_OF_CUP + Cup->HEAT_OF_CUP
}

fact Influences {
  influences = HEAT_OF_COFFEE->TEMPERATURE_OF_COFFEE + HEAT_OF_CUP->TEMPERATURE_OF_CUP
}

fact NoTouchNoFlow {
  all t: ThermalThing |
    (no t.touches & (Cup + Coffee)) implies (no greaterThan and no HeatFlow)
}

fact TouchIff {
  all t: ThermalThing |
    (some t.touches & (Cup + Coffee)) iff
      (HEAT_OF_COFFEE->HEAT_OF_CUP in greaterThan
       or HEAT_OF_CUP->HEAT_OF_COFFEE in greaterThan
       or (HEAT_OF_CUP->HEAT_OF_COFFEE not in greaterThan
           and HEAT_OF_COFFEE->HEAT_OF_CUP not in greaterThan))
}

fact EquilibriumNoFlow {
  all t: ThermalThing |
    ((some t.touches & (Cup + Coffee))
      and HEAT_OF_CUP->HEAT_OF_COFFEE not in greaterThan
      and HEAT_OF_COFFEE->HEAT_OF_CUP not in greaterThan)
    implies
      (HEAT_OF_CUP not in HeatFlow.increases
       and HEAT_OF_COFFEE not in HeatFlow.increases
       and HEAT_OF_COFFEE not in HeatFlow.decreases
       and HEAT_OF_CUP not in HeatFlow.decreases)
}

fact CupHotter {
  all t: ThermalThing |
    ((some t.touches & (Cup + Coffee))
      and HEAT_OF_CUP->HEAT_OF_COFFEE in greaterThan)
    implies
      (HEAT_OF_COFFEE.state = INCREASING
       and TEMPERATURE_OF_COFFEE.state = INCREASING
       and HEAT_OF_CUP.state = DECREASING
       and TEMPERATURE_OF_CUP.state = DECREASING
       and HeatFlow.increases = HEAT_OF_COFFEE
       and HeatFlow.decreases = HEAT_OF_CUP)
}

fact CoffeeHotter {
  all t: ThermalThing |
    ((some t.touches & (Cup + Coffee))
      and HEAT_OF_COFFEE->HEAT_OF_CUP in greaterThan)
    implies
      (HEAT_OF_COFFEE.state = DECREASING
       and TEMPERATURE_OF_COFFEE.state = DECREASING
       and HEAT_OF_CUP.state = INCREASING
       and TEMPERATURE_OF_CUP.state = INCREASING
       and HeatFlow.increases = HEAT_OF_CUP
       and HeatFlow.decreases = HEAT_OF_COFFEE)
}