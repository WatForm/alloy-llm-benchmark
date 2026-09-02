abstract sig QuallitativeState {}

one sig INCREASING extends QuallitativeState {}
one sig DECREASING extends QuallitativeState {}
one sig NOCHANGE extends QuallitativeState {}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig ThermalThing extends Thing {}

one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}
one sig Coffee extends Substance {}

sig ThermalProperty extends Property {}

sig HEAT extends ThermalProperty {
  greaterThan: lone HEAT
}

sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE extends HEAT {}
one sig HEAT_OF_CUP extends HEAT {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

one sig HeatFlow extends Process {}

fact {
  QuallitativeState = INCREASING + DECREASING + NOCHANGE
  Thing = ThermalThing
  ThermalThing = Substance + Cup
  Substance = Coffee
  ThermalProperty = Property
  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
  Process = HeatFlow
}

fact {
  all h: HEAT | h not in h.greaterThan
  greaterThan != ~greaterThan
}

fact {
  all t: Thing | t not in t.touches
  touches = ~touches
}

fact {
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  all t: Thing - Coffee - Cup | no t.hasProperty
}

fact {
  influences =
    (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
    (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)
}

fact {
  all t: ThermalThing |
    (no (t.touches & (Cup + Coffee))) implies
      (no greaterThan and no HeatFlow)
}

fact {
  all t: ThermalThing |
    (some (t.touches & (Cup + Coffee))) iff
      (
        HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan or
        HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan or
        (
          HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and
          HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
        )
      )
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and
      HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
    ) implies {
      HEAT_OF_CUP not in HeatFlow.increases
      HEAT_OF_COFFEE not in HeatFlow.increases
      HEAT_OF_COFFEE not in HeatFlow.decreases
      HEAT_OF_CUP not in HeatFlow.decreases
    }
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
    ) implies {
      HEAT_OF_COFFEE.state = INCREASING
      TEMPERATURE_OF_COFFEE.state = INCREASING
      HEAT_OF_CUP.state = DECREASING
      TEMPERATURE_OF_CUP.state = DECREASING
      HeatFlow.increases = HEAT_OF_COFFEE
      HeatFlow.decreases = HEAT_OF_CUP
    }
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
    ) implies {
      HEAT_OF_COFFEE.state = DECREASING
      TEMPERATURE_OF_COFFEE.state = DECREASING
      HEAT_OF_CUP.state = INCREASING
      TEMPERATURE_OF_CUP.state = INCREASING
      HeatFlow.increases = HEAT_OF_CUP
      HeatFlow.decreases = HEAT_OF_COFFEE
    }
}