abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig ThermalProperty extends Property {}

sig HEAT extends ThermalProperty {
  greaterThan: lone HEAT
}

sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig ThermalThing extends Thing {}

sig Substance extends ThermalThing {}

one sig Coffee extends Substance {}

one sig Cup extends ThermalThing {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

one sig HeatFlow extends Process {}

fact {
  Thing = ThermalThing
  one Substance
  Substance = Coffee
  ThermalThing = Substance + Cup
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
  hasProperty =
    (Coffee -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE)) +
    (Cup -> (TEMPERATURE_OF_CUP + HEAT_OF_CUP))
}

fact {
  influences =
    (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
    (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)
}

fact {
  all t: ThermalThing |
    no (t.touches & (Cup + Coffee)) => (no greaterThan and no HeatFlow)
}

fact {
  all t: ThermalThing |
    (
      (some (t.touches & (Cup + Coffee))) =>
      (
        ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan) or
        ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan) or
        (
          not ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan) and
          not ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan)
        )
      )
    )
    and
    (
      (
        ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan) or
        ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan) or
        (
          not ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan) and
          not ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan)
        )
      ) =>
      (some (t.touches & (Cup + Coffee)))
    )
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      not ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan) and
      not ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan)
    ) =>
    (
      HEAT_OF_CUP not in HeatFlow.increases and
      HEAT_OF_COFFEE not in HeatFlow.increases and
      HEAT_OF_COFFEE not in HeatFlow.decreases and
      HEAT_OF_CUP not in HeatFlow.decreases
    )
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      ((HEAT_OF_CUP -> HEAT_OF_COFFEE) in greaterThan)
    ) =>
    (
      HEAT_OF_COFFEE.state = INCREASING and
      TEMPERATURE_OF_COFFEE.state = INCREASING and
      HEAT_OF_CUP.state = DECREASING and
      TEMPERATURE_OF_CUP.state = DECREASING and
      increases.HEAT_OF_COFFEE = HeatFlow and
      decreases.HEAT_OF_CUP = HeatFlow
    )
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      ((HEAT_OF_COFFEE -> HEAT_OF_CUP) in greaterThan)
    ) =>
    (
      HEAT_OF_COFFEE.state = DECREASING and
      TEMPERATURE_OF_COFFEE.state = DECREASING and
      HEAT_OF_CUP.state = INCREASING and
      TEMPERATURE_OF_CUP.state = INCREASING and
      increases.HEAT_OF_CUP = HeatFlow and
      decreases.HEAT_OF_COFFEE = HeatFlow
    )
}