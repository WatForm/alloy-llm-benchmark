sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

sig ThermalThing in Thing {}

one sig Substance in ThermalThing {}

one sig Cup in ThermalThing {}

one sig Coffee in Substance {}

sig ThermalProperty in Property {}

sig HEAT in ThermalProperty {
  greaterThan: lone HEAT
}

sig TEMPERATURE in ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE in TEMPERATURE {}

one sig TEMPERATURE_OF_CUP in TEMPERATURE {}

one sig HEAT_OF_COFFEE in HEAT {}

one sig HEAT_OF_CUP in HEAT {}

one sig HeatFlow in Process {}

fact {
  Thing in ThermalThing
  ThermalThing = Substance + Cup
  no Substance & Cup
  Coffee = Substance

  ThermalProperty = Property
  no HEAT & TEMPERATURE

  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
  no TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP

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
    (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
    (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)

  all t: ThermalThing |
    (Cup not in t.touches and Coffee not in t.touches) implies
      (no greaterThan and no HeatFlow)

  all t: ThermalThing |
    (Cup in t.touches or Coffee in t.touches) iff
      (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan or
       HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan or
       (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and
        HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan))

  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches) and
     HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and
     HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan) implies
      (HEAT_OF_CUP not in HeatFlow.increases and
       HEAT_OF_COFFEE not in HeatFlow.increases and
       HEAT_OF_COFFEE not in HeatFlow.decreases and
       HEAT_OF_CUP not in HeatFlow.decreases)

  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches) and
     HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) implies
      (HEAT_OF_COFFEE.state = INCREASING and
       TEMPERATURE_OF_COFFEE.state = INCREASING and
       HEAT_OF_CUP.state = DECREASING and
       TEMPERATURE_OF_CUP.state = DECREASING and
       HEAT_OF_COFFEE.~increases = HeatFlow and
       HEAT_OF_CUP.~decreases = HeatFlow)

  all t: ThermalThing |
    ((Cup in t.touches or Coffee in t.touches) and
     HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) implies
      (HEAT_OF_COFFEE.state = DECREASING and
       TEMPERATURE_OF_COFFEE.state = DECREASING and
       HEAT_OF_CUP.state = INCREASING and
       TEMPERATURE_OF_CUP.state = INCREASING and
       HEAT_OF_CUP.~increases = HeatFlow and
       HEAT_OF_COFFEE.~decreases = HeatFlow)
}