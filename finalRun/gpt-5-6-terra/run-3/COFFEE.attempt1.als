sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig QuallitativeState {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

sig ThermalThing in Thing {}

one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}
one sig Coffee extends Substance {}

sig ThermalProperty in Property {}

sig HEAT extends ThermalProperty {
  greaterThan: lone HEAT
}

sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE extends HEAT {}
one sig HEAT_OF_CUP extends HEAT {}

one sig INCREASING extends QuallitativeState {}
one sig DECREASING extends QuallitativeState {}
one sig NOCHANGE extends QuallitativeState {}

one sig HeatFlow extends Process {}

fact {
  Thing = ThermalThing
  ThermalThing = Substance + Cup
  Substance = Coffee

  ThermalProperty = Property

  QuallitativeState = INCREASING + DECREASING + NOCHANGE

  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP

  Process = HeatFlow

  no (iden & greaterThan)
  greaterThan != ~greaterThan

  no (iden & touches)
  touches = ~touches

  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
  all t: Thing - Coffee - Cup | no t.hasProperty

  influences =
    HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE +
    HEAT_OF_CUP -> TEMPERATURE_OF_CUP

  all t: ThermalThing |
    no (t.touches & (Cup + Coffee)) implies
      (no greaterThan and no HeatFlow)

  all t: ThermalThing |
    some (t.touches & (Cup + Coffee)) iff
      (
        (HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan or
        (HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan or
        (
          (HEAT_OF_COFFEE -> HEAT_OF_CUP) not in greaterThan and
          (HEAT_OF_CUP -> HEAT_OF_COFFEE) not in greaterThan
        )
      )

  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      (HEAT_OF_COFFEE -> HEAT_OF_CUP) not in greaterThan and
      (HEAT_OF_CUP -> HEAT_OF_COFFEE) not in greaterThan
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
      (HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan
    ) implies
      (
        HEAT_OF_COFFEE.state = INCREASING and
        TEMPERATURE_OF_COFFEE.state = INCREASING and
        HEAT_OF_CUP.state = DECREASING and
        TEMPERATURE_OF_CUP.state = DECREASING and
        HEAT_OF_COFFEE.~increases = HeatFlow and
        HEAT_OF_CUP.~decreases = HeatFlow
      )

  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      (HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan
    ) implies
      (
        HEAT_OF_COFFEE.state = DECREASING and
        TEMPERATURE_OF_COFFEE.state = DECREASING and
        HEAT_OF_CUP.state = INCREASING and
        TEMPERATURE_OF_CUP.state = INCREASING and
        HEAT_OF_CUP.~increases = HeatFlow and
        HEAT_OF_COFFEE.~decreases = HeatFlow
      )
}