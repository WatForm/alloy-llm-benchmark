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

sig ThermalProperty in Property {}

sig HEAT in ThermalProperty {
  greaterThan: lone HEAT
}

sig TEMPERATURE in ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE in TEMPERATURE {}
one sig TEMPERATURE_OF_CUP in TEMPERATURE {}

one sig HEAT_OF_COFFEE in HEAT {}
one sig HEAT_OF_CUP in HEAT {}

sig ThermalThing in Thing {}

one sig Substance in ThermalThing {}

one sig Cup in ThermalThing {}

one sig Coffee in Substance {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

one sig HeatFlow in Process {}

fact {
  Thing = ThermalThing
  ThermalThing = Substance + Cup
  no Substance & Cup
  Substance = Coffee
}

fact {
  ThermalProperty = Property
  no HEAT & TEMPERATURE
  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
  no TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP
  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
  no HEAT_OF_COFFEE & HEAT_OF_CUP
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
    no (t.touches & (Cup + Coffee)) =>
      (no greaterThan and no HeatFlow)
}

fact {
  all t: ThermalThing |
    (some (t.touches & (Cup + Coffee))) <=>
      (
        (HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan) or
        (HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan) or
        (
          not (HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan) and
          not (HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan)
        )
      )
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      not (HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan) and
      not (HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan)
    ) =>
      (
        not (HEAT_OF_CUP in HeatFlow.increases) and
        not (HEAT_OF_COFFEE in HeatFlow.increases) and
        not (HEAT_OF_COFFEE in HeatFlow.decreases) and
        not (HEAT_OF_CUP in HeatFlow.decreases)
      )
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan
    ) =>
      (
        HEAT_OF_COFFEE.state = INCREASING and
        TEMPERATURE_OF_COFFEE.state = INCREASING and
        HEAT_OF_CUP.state = DECREASING and
        TEMPERATURE_OF_CUP.state = DECREASING and
        HEAT_OF_COFFEE.(~increases) = HeatFlow and
        HEAT_OF_CUP.(~decreases) = HeatFlow
      )
}

fact {
  all t: ThermalThing |
    (
      some (t.touches & (Cup + Coffee)) and
      HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan
    ) =>
      (
        HEAT_OF_COFFEE.state = DECREASING and
        TEMPERATURE_OF_COFFEE.state = DECREASING and
        HEAT_OF_CUP.state = INCREASING and
        TEMPERATURE_OF_CUP.state = INCREASING and
        HEAT_OF_CUP.(~increases) = HeatFlow and
        HEAT_OF_COFFEE.(~decreases) = HeatFlow
      )
}