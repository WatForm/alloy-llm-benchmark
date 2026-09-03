enum QuallitativeState {
  INCREASING,
  DECREASING,
  NOCHANGE
}

abstract sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig ThermalProperty extends Property {}

abstract sig HEAT extends ThermalProperty {
  greaterThan: lone HEAT
}

abstract sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

abstract sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

abstract sig ThermalThing extends Thing {}

one sig Substance, Cup extends ThermalThing {}

one sig Coffee extends Substance {}

abstract sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

one sig HeatFlow extends Process {}

fact {
  no iden & greaterThan
  greaterThan != ~greaterThan

  no iden & touches
  touches = ~touches

  hasProperty =
    (Coffee -> TEMPERATURE_OF_COFFEE) +
    (Coffee -> HEAT_OF_COFFEE) +
    (Cup -> TEMPERATURE_OF_CUP) +
    (Cup -> HEAT_OF_CUP)

  influences =
    (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
    (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)

  all t: ThermalThing |
    no (t.touches & (Cup + Coffee)) implies
      (no greaterThan and no HeatFlow)

  all t: ThermalThing |
    some (t.touches & (Cup + Coffee)) iff
      (
        HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan or
        HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan or
        (
          HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan and
          HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
        )
      )

  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan and
      HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
    ) implies
      (
        HEAT_OF_CUP not in HeatFlow.increases and
        HEAT_OF_COFFEE not in HeatFlow.increases and
        HEAT_OF_COFFEE not in HeatFlow.decreases and
        HEAT_OF_CUP not in HeatFlow.decreases
      )

  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
    ) implies
      (
        HEAT_OF_COFFEE.state = INCREASING and
        TEMPERATURE_OF_COFFEE.state = INCREASING and
        HEAT_OF_CUP.state = DECREASING and
        TEMPERATURE_OF_CUP.state = DECREASING and
        HeatFlow.increases = HEAT_OF_COFFEE and
        HeatFlow.decreases = HEAT_OF_CUP
      )

  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
    ) implies
      (
        HEAT_OF_COFFEE.state = DECREASING and
        TEMPERATURE_OF_COFFEE.state = DECREASING and
        HEAT_OF_CUP.state = INCREASING and
        TEMPERATURE_OF_CUP.state = INCREASING and
        HeatFlow.increases = HEAT_OF_CUP and
        HeatFlow.decreases = HEAT_OF_COFFEE
      )
}