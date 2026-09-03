abstract sig Thing {
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

abstract sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

abstract sig ThermalThing extends Thing {}

one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}
one sig Coffee extends Substance {}

sig ThermalProperty extends Property {}

abstract sig HEAT extends ThermalProperty {
  greaterThan: lone HEAT
}

abstract sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE extends HEAT {}
one sig HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

fact {
  ThermalProperty = Property

  all h: HEAT | h not in h.greaterThan
  not (greaterThan = ~greaterThan)

  all t: Thing | t not in t.touches
  touches = ~touches

  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
  no (Thing - Coffee - Cup).hasProperty

  influences =
    (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
    (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)

  all t: ThermalThing |
    (Cup not in t.touches and Coffee not in t.touches) implies
      (no greaterThan and no HeatFlow)

  all t: ThermalThing |
    (Cup in t.touches or Coffee in t.touches) iff
      ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan or
       (HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan or
       ((HEAT_OF_CUP -> HEAT_OF_COFFEE) not in greaterThan and
        (HEAT_OF_COFFEE -> HEAT_OF_CUP) not in greaterThan))

  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches) and
     (HEAT_OF_CUP -> HEAT_OF_COFFEE) not in greaterThan and
     (HEAT_OF_COFFEE -> HEAT_OF_CUP) not in greaterThan) implies
      (HEAT_OF_CUP not in HeatFlow.increases and
       HEAT_OF_COFFEE not in HeatFlow.increases and
       HEAT_OF_COFFEE not in HeatFlow.decreases and
       HEAT_OF_CUP not in HeatFlow.decreases)

  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches) and
     (HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan) implies
      (HEAT_OF_COFFEE.state = INCREASING and
       TEMPERATURE_OF_COFFEE.state = INCREASING and
       HEAT_OF_CUP.state = DECREASING and
       TEMPERATURE_OF_CUP.state = DECREASING and
       HeatFlow.increases = HEAT_OF_COFFEE and
       HeatFlow.decreases = HEAT_OF_CUP)

  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches) and
     (HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan) implies
      (HEAT_OF_COFFEE.state = DECREASING and
       TEMPERATURE_OF_COFFEE.state = DECREASING and
       HEAT_OF_CUP.state = INCREASING and
       TEMPERATURE_OF_CUP.state = INCREASING and
       HeatFlow.increases = HEAT_OF_CUP and
       HeatFlow.decreases = HEAT_OF_COFFEE)
}